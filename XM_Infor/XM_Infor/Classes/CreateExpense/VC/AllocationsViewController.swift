//
//  AllocationsViewController.swift
//  XM_Infor
//
//  Created by Robin He on 07/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
@objc
protocol AllocationsItemsDelegate:NSObjectProtocol {
    
    @objc optional func AllocationsReturnWithItems(allocations: [CorpDataModel],colorStrItems:[String],amountItems:NSMutableArray,subPerLabGFrameItems:[String],isDSAllocation:Bool,pencentItems:[Float])
    
    
}
class AllocationsViewController: XMBaseViewController,AddAllocationTitleViewDelegate{

    var costCenterTotalAmount:Float = 0
    var totalAmount:String = ""
    var option = 0
    var type = ""
    
    var defaultDisplayName = ""
    var _allocation = [String:Any]()
    
    var allocationsDict:NSMutableDictionary = [:]
    var subLabelItems = [UILabel]()

    weak var delegate:AllocationsItemsDelegate?
    lazy var AllocationItems = [CorpDataModel]()
    lazy var uidItems = [Int]()
    var subPerLabFrameStrItems = [String]()
    
    var indexPRow:Int = 0
    var isDataStoreAllocation = false
    
    var textFieldCell = AlloTableViewCell()
    var sunperId:Int = 0
    var previousIndexRow:Int?
    var isAddClick = false
    var mtextField:UITextField?
    
    var AmountItems:NSMutableArray? = []
    lazy var colorItrems = [UIColor]() 
    var colorStrItems = [String]()
    var AlloHeadView:AllocationHeaderView?
    var isClickAddButton = false
    var percentItems = [Float]()
    var cellTotalMoney:Float = 0
    
    
    lazy var AllocationsTView:UITableView = {
        let cet = UITableView(frame:CGRect(x:0,y:getLength(leng: 0),width:SCREEN_WIDTH,height:SCREEN_HEIGHT - 64))
        cet.delegate = self
        cet.dataSource = self
        cet.register(UINib.init(nibName: "AlloTableViewCell", bundle:nil), forCellReuseIdentifier: "AlloTableViewCell")
        cet.rowHeight = 105
        return cet
    }()
  
    
    lazy var AddAllocationTitleV:AddAllocationTitleView = {

        let titlev = AddAllocationTitleView()
        titlev.x = SCREEN_WIDTH - 110
        titlev.y = 10
        titlev.width = 100
        titlev.height = 130
        titlev.backgroundColor = UIColor.black
        titlev.alpha = 0.7
        titlev.delegate = self
        self.view.addSubview(titlev)
        return titlev
    }()
    
    lazy var upArrowImage:UIImageView = {
        
        let upImageV = UIImageView()
        upImageV.x = SCREEN_WIDTH - 40
        upImageV.y = 0
        upImageV.width = 20
        upImageV.height = 10
        upImageV.image = UIImage(named: "detail_up_arrow")
        self.view.addSubview(upImageV)
        return upImageV
    }()
    
//    var sw:UISwitch?
   
    
    override func viewDidAppear(_ animated: Bool) {
        isClickAddButton = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = UIColor.white
        title = "Allocations"
        
        setupNav()
        setupUI()
        loadData()
        addNotificationObserver(name: "CostCenterNotification")
        addNotificationObserver(name: NSNotification.Name.UIKeyboardWillShow.rawValue)

        if isDataStoreAllocation {
            for amo in AmountItems! {
                costCenterTotalAmount += Float(amo as!String)!
            }
            
        } else {
            for amo in AmountItems! {
                
                if amo as!String == "" {
                    continue
                }
                costCenterTotalAmount += Float(amo as!String)!
            }
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
       
        view.endEditing(false)
        UIView.animate(withDuration: 0, animations: {
            var frame = self.view.frame
            frame.origin.y = 64
            self.view.frame = frame
        }, completion: nil)

    }
    
    override func handleNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String: Any]

        if notification.name == Notification.Name(rawValue: "CostCenterNotification") {
            
            AllocationItems.append(userInfo["CostCenterModel"] as! CorpDataModel)
            let colorStr = UIColor.randomRGBStr()
            colorStrItems.append(colorStr) //为了方便从数据库中找
            colorItrems.append(UIColor.randomRGBWithRGBStr(colorStr))
            percentItems.append(0.0)
            
            AmountItems?.add("")
            AllocationsTView.reloadData()

            
        } else if notification.name == NSNotification.Name.UIKeyboardWillShow {
        
            let userinfo: NSDictionary = notification.userInfo! as NSDictionary
            let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
            let keyboardRec = (nsValue as AnyObject).cgRectValue
            let height = keyboardRec?.size.height

            if isClickAddButton {
                return
            }
            UIView.animate(withDuration: 0, animations: {
                var frame = self.view.frame
                if SCREEN_HEIGHT - (self.textFieldCell.y - self.AllocationsTView.contentOffset.y + 64) < height!{
                    frame.origin.y = -height! + 64
                }
                self.view.frame = frame
            }, completion: nil)
            
        }
   }
    
    
    func AddAllocationTitleViewWithButon(btn: UIButton) {
        
        if btn.titleLabel!.text == "CostCenter"{
            if costCenterTotalAmount == Float(totalAmount) {
                SVProgressHUD.showInfo(withStatus: "TotalAmount up !")
                return
            }
            let vc = AddAllocationCostCenterVC()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            
            
            
        }
        isAddClick = !isAddClick
        AddAllocationTitleV.isHidden = true
        upArrowImage.isHidden = true

    }

}

extension AllocationsViewController{
    
    func loadData(){

        if allocationsDict != [:] {
            
                AllocationItems = allocationsDict.object(forKey: "allocationCostCenters") as! [CorpDataModel]
                AmountItems = allocationsDict.object(forKey: "allocationAmounts") as? NSMutableArray
                subPerLabFrameStrItems = allocationsDict.object(forKey: "allocationSubPerLabFrameItems") as! [String]
                colorStrItems = allocationsDict.object(forKey: "allocationColorStrItems") as! [String]
                for colorStr in colorStrItems {
                  colorItrems.append(UIColor.randomRGBWithRGBStr(colorStr))
                }
                
                // post Notification for headerview
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "amountTextfieldPushEditing"), object: nil, userInfo: ["amountTextfieldItems":AmountItems!,"totalMoney":self.totalAmount,"SubPerLabItems":subPerLabFrameStrItems,"colorStrItems":colorStrItems])
            
                AllocationsTView.reloadData()
        } else {
            
            if self.defaultDisplayName != ""{
                let alloCorpModel = CorpDataModel()
                alloCorpModel.displayName = self.defaultDisplayName
                for allo in _allocation{
                    if allo.key == "costCenterName"{
                        let dict = ["type":29500]
                        alloCorpModel.jsonString = dict.getJSONStringFromDictionary()
                        alloCorpModel.uid = allo.value as!Int
                        break
                    }
                }
                
                AllocationItems = [alloCorpModel]
                AmountItems = [self.totalAmount]
                colorStrItems.append("127.0 192.0 193.0")
                subPerLabFrameStrItems.append("{{0, 0}, {300.00000762939453, 20}}")
                for colorStr in colorStrItems {
                    colorItrems.append(UIColor.randomRGBWithRGBStr(colorStr))
                }
                // post Notification for headerview
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "amountTextfieldPushEditing"), object: nil, userInfo: ["amountTextfieldItems":AmountItems!,"totalMoney":self.totalAmount,"SubPerLabItems":subPerLabFrameStrItems,"colorStrItems":colorStrItems])
                
                AllocationsTView.reloadData()
            }
           
        }
    }
    func setupUI() {
        
        // AllocationsTView tableHeaderView
        AlloHeadView = Bundle.main.loadNibNamed("AllocationHeaderView", owner: nil, options: nil)?.first as? AllocationHeaderView
        AlloHeadView?.delegate = self
        AlloHeadView?.totalAmountLabel.text = "$ " + self.totalAmount
        AlloHeadView?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH , height: getLength(leng: 200))
        view.addSubview(AllocationsTView)
        AllocationsTView.tableHeaderView = AlloHeadView
    

    }
    func setupNav() {
        
        let item1 = UIBarButtonItem(title:"Back",style: UIBarButtonItemStyle.plain, target: self, action: #selector(returnClick))
        navigationItem.leftBarButtonItem = item1
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let item2 = UIBarButtonItem(title:"Add",style: UIBarButtonItemStyle.plain, target: self, action: #selector(addClick))
         navigationItem.rightBarButtonItem = item2
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
    }


    func returnClick() {
        
      
     
        if mtextField != nil {
             textFieldDidEndEditing(mtextField!)
        }
        var subLabFramesStrs = [String]()
       
        for sublabel in AlloHeadView!.subPerLabelitems {
            let frameStr =  NSStringFromCGRect(sublabel.frame)
            subLabFramesStrs.append(frameStr)
        }
        
        if Float(totalAmount)! == 0 {
            delegate?.AllocationsReturnWithItems!(allocations: AllocationItems,colorStrItems: colorStrItems,amountItems:AmountItems!, subPerLabGFrameItems: subLabFramesStrs, isDSAllocation: isDataStoreAllocation,pencentItems:percentItems) // delegate method
            
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        percentItems.removeAll()
        for amount in AmountItems! {
            if (amount as!String) != "" {
                let percent = Float(amount as!String)! / Float(totalAmount)!
                percentItems.append(percent)
            }else{
                percentItems.append(0.0)
            }
        }
        delegate?.AllocationsReturnWithItems!(allocations: AllocationItems,colorStrItems: colorStrItems,amountItems:AmountItems!, subPerLabGFrameItems: subLabFramesStrs, isDSAllocation: isDataStoreAllocation,pencentItems:percentItems) // delegate method
      
            self.navigationController?.popViewController(animated: true)
    }
    func addClick() {
//
        isClickAddButton = true
        if Float(totalAmount)! == 0 {
            let vc = AddAllocationCostCenterVC()
            vc.option = option
            vc.type = type
            navigationController?.pushViewController(vc, animated: true)
            
            return
        }
        if mtextField != nil {
            textFieldDidEndEditing(mtextField!)
        }
        var subLabFramesStrs = [String]()

        for sublabel in AlloHeadView!.subPerLabelitems {
            let frameStr =  NSStringFromCGRect(sublabel.frame)
            subLabFramesStrs.append(frameStr)
        }

        percentItems.removeAll()
        for amount in AmountItems! {
            if (amount as!String) != "" {
                let percent = Float(amount as!String)! / Float(totalAmount)!
                percentItems.append(percent)
            }
        }

        var resuleAmount:Float = 0
        for amount in AmountItems! {
            print(amount)
            if amount as! String == ""{
                let alertView = UIAlertView(title: "Reminder", message: "Please write in amount first ! ", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
                return
            }
          resuleAmount += Float(amount as! String)!
        }
//        view.endEditing(true)
        if Float(self.totalAmount)! == resuleAmount {
            let alertView = UIAlertView(title: "Reminder", message: "Allocation amount is already full! If you want to add other allocation, please redistribute amount... ", delegate: self, cancelButtonTitle: "OK")
            alertView.show()
            return
        }
        let vc = AddAllocationCostCenterVC()
        vc.option = option
        vc.type = type
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AllocationsViewController:UITextFieldDelegate{

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldCell = textField.superview?.superview as! AlloTableViewCell
        mtextField = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard AllocationsTView.indexPath(for: (textField.superview?.superview as! AlloTableViewCell)) != nil,
             let indexP = AllocationsTView.indexPath(for: (textField.superview?.superview as! AlloTableViewCell)),
             let amountText = (AllocationsTView.cellForRow(at: indexP) as! AlloTableViewCell).amountTextfield.text
            else {
                return
        }
        if amountText == "" {
            return
        }
        
        if Float(totalAmount)! == 0 {
            
            AmountItems?.replaceObject(at: indexP.row, with: amountText)
            var totalMoney:Float = 0
            for amount in AmountItems!{
                if amount as!String == ""{
                    continue
                }
                totalMoney += Float(amount as!String)!
            }
            cellTotalMoney = totalMoney
            percentItems.removeAll()
            for amount in AmountItems!{
                if amount as!String == ""{
                    percentItems.append(0.0)
                }else{
                    let everyPercent = Float(amount as!String)! / totalMoney
                    percentItems.append(everyPercent)
                }
            
            }
            if totalMoney != 0{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "amountTextfieldEndEditing"), object: nil, userInfo: ["amountTextfieldItems":AmountItems!,"markLabColor":colorItrems[indexP.row],"indexPRow":indexP.row,"totalMoney":"\(totalMoney)"])
                if AlloHeadView!.subPerLabelitems.count == 1 {
                    subPerLabFrameStrItems += AlloHeadView!.subPerLabelFrameitems
                } else {
                    subPerLabFrameStrItems = AlloHeadView!.subPerLabelFrameitems
                }
            }
             AllocationsTView.reloadData()
            
        }else{
            if (AmountItems?.count)! > indexP.row {
                costCenterTotalAmount -= (AmountItems?[indexP.row] as! NSString).floatValue
            }
            costCenterTotalAmount += (amountText as NSString).floatValue
            if costCenterTotalAmount > Float(totalAmount)!{
                SVProgressHUD.showError(withStatus: "The total allocations money was't fully !")
                costCenterTotalAmount -= (amountText as NSString).floatValue
                (AllocationsTView.cellForRow(at: indexP) as! AlloTableViewCell).amountTextfield.text = ""
                return
            }
            AmountItems?.replaceObject(at: indexP.row, with: amountText)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "amountTextfieldEndEditing"), object: nil, userInfo: ["amountTextfieldItems":AmountItems!,"markLabColor":colorItrems[indexP.row],"indexPRow":indexP.row,"totalMoney":self.totalAmount])
            if AlloHeadView!.subPerLabelitems.count == 1 {
                subPerLabFrameStrItems += AlloHeadView!.subPerLabelFrameitems
            } else {
                subPerLabFrameStrItems = AlloHeadView!.subPerLabelFrameitems
            }
            AllocationsTView.reloadData()
        }
       
    }
}

extension AllocationsViewController:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AmountItems!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlloTableViewCell")! as! AlloTableViewCell
        if AllocationItems[indexPath.row].displayName != "" {
            
            cell.allocationName.text = AllocationItems[indexPath.row].displayName
            if AllocationItems[indexPath.row].jsonString.getDictionaryFromString()["type"] as!Int == 29500 {
                cell.allocationTypeLabel.text = "costCenter"
            }else{
                cell.allocationTypeLabel.text = "projectNumber"
            }
        
        cell.amountTextfield.text = AmountItems?[indexPath.row] as? String
        cell.markLab.backgroundColor = colorItrems[indexPath.row]
        cell.amountTextfield.delegate = self
        cell.amountTextfield.isHidden = false
        cell.amountSymbol.isHidden = false
        if Float(cell.amountTextfield.text!) != nil{
           
            let amountStr = Float(cell.amountTextfield.text!)
            if totalAmount == "0"{
                if AmountItems?.count == 1{
                      cell.pencentLabel.text = "100%"
                }else{
                     cell.pencentLabel.text = String(format: "%.f%%", percentItems[indexPath.row] * 100)
                }
            }else{
                let value = amountStr! / Float(totalAmount)!
                cell.pencentLabel.text = String(format: "%.f%%", value * 100)
            }
           
        } else {
            cell.pencentLabel.text = "0%"
        }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
           
            indexPRow = indexPath.row
            AllocationItems.remove(at: indexPath.row)
            costCenterTotalAmount -= (AmountItems?[indexPath.row] as! NSString).floatValue
            colorStrItems.remove(at: indexPath.row)
            colorItrems.remove(at: indexPath.row)
            percentItems.remove(at: indexPath.row)
            if AmountItems?[indexPath.row] as! String == "" {
                AmountItems?.removeObject(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                return
            }
           
            AmountItems?.removeObject(at: indexPath.row)
          
            var totalMoney:Float = 0
            for amount in AmountItems!{
                totalMoney += Float(amount as!String)!
            }
            cellTotalMoney = totalMoney
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "amountTextfieldEditingDelete"), object: nil, userInfo: ["amountTextfieldItems":AmountItems!,"indexPRow":indexPath.row,"isDelete":true,"totalMoney":"\(cellTotalMoney)"])
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
        }
    }
}


extension AllocationsViewController:AllocationHeaderViewDelegate{

    func AllocationHeaderAmountSwitch(switch swit: UISwitch?) {
        
        let indexArray = AllocationsTView.indexPathsForVisibleRows
            for indexP in indexArray! {
                let visiCell = AllocationsTView.cellForRow(at: indexP) as! AlloTableViewCell
                if (swit?.isOn)! {
//                    visiCell.percentTextfield?.isHidden = true
//                    visiCell.percentSymbol?.isHidden = true
                    visiCell.amountTextfield.isHidden = false
                    visiCell.amountSymbol.isHidden = false
                
                } else {
//                    visiCell.percentTextfield?.isHidden = false
//                    visiCell.percentSymbol?.isHidden = false
                    visiCell.amountTextfield.isHidden = true
                    visiCell.amountSymbol.isHidden = true
                  
                    let amountStr = Float(visiCell.amountTextfield.text!)
                    let value = amountStr! / Float(totalAmount)!
//                    visiCell.percentTextfield?.text = String(format: "%.f", value * 100)

                }
        }
    }
}









