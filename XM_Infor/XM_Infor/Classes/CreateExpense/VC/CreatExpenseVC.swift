//
//  CreatExpenseVC.swift
//  XM_Infor
//
//  Created by Robin He on 04/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
import RealmSwift
import Photos
class CreatExpenseVC: XMBaseViewController,UITableViewDelegate,UITableViewDataSource{
    
    var expenseType = Int()
    var textFieldCell = DetailMsgTVCell()
    var items = [ExpenseFieldItem]()
    var expenseName = ""
    var imageName = ""
    var currencyItems = [CorpDataModel]()
    var currencyArray = [String]()
    var currencySymbol = ""
    var numDateStr = ""
    var CEView:ExpenseMsgView?
    var indexPathRow = 1
    var contentlabItems:NSMutableArray = []
   
    var enpenseFielDict = [String:Any]()
    var enpenseDefaultConfigDic = [String:Any]()
    var displayUIDic = [String:Any]()
    
    var superClientId:Int = 0
    
    var allocationCostCenters = [CorpDataModel]()
    var allocationColors = [UIColor]()
    var allocationAmounts:NSMutableArray = []
    var allocationColorStrItems = [String]()
    
    var subPerLabFrameStrItems = [String]()
    var isDataSAllocation = false
     var percentArray = [Float]()
    
    var isExpenseListType = false // type from expenselist clicked to create an expense
    var isCcExpenseListType = false
     var relamExpenseClientId = ""
    
    var previousIndexRow:Int?
    var isAgainPrepareDone = false
    var DetailMsgTVCellItems = [DetailMsgTVCell]()
    var expenseModel:ExpensesModel?
    var isClickCell = false
    
    lazy var CETView:UITableView = {
        let cet = UITableView(frame:CGRect(x:0,y:0,width:SCREEN_WIDTH,height:SCREEN_HEIGHT-64))
        cet.delegate = self
        cet.dataSource = self
        cet.register(UINib.init(nibName: "DetailMsgTVCell", bundle:nil), forCellReuseIdentifier: "DetailMsgTVCell")
        cet.rowHeight = 65
        return cet
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        isClickCell = false
        if isExpenseListType || isCcExpenseListType{
            if expenseModel?.jsonString.getDictionaryFromString()["expenseType"] != nil{
                expenseType = expenseModel?.jsonString.getDictionaryFromString()["expenseType"] as! Int
            }
            if expenseModel?.status == "done" {// can't be editing
                // since data was setted up , so, must stop edit !
                for  sub  in CEView!.subviews{
                    sub.isUserInteractionEnabled = false
                }
                for cell in DetailMsgTVCellItems {
                    if cell.MsgName.text == "Allocation" {
                        continue
                    }
                    cell.isUserInteractionEnabled = false
                }
                DetailMsgTVCellItems = [] //
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        initView()
        loadData()
        setNotificationObserver()
    }
    
    deinit {
        print("CreatExpenseVC被销毁了---")
        removeNotificationObserver()
    }
}

extension CreatExpenseVC{
    func handReferenceData(jsonStringDict:[String:Any],expensefieldItems:[[String:Any]]) {
        var tempItems = [ExpenseFieldItem]()
        let referenceDict = jsonStringDict["-reference"] as! NSDictionary
        for fieldict in  expensefieldItems{
            let item =  ExpenseFieldItem(dict: fieldict)
            if item.label == "Date" || item.label == "Amount" || item.label == "Currency" || item.label == "Note" || item.label == "Expense Type"{
                continue
            }
            tempItems.append(item)
        }
        for (i,tempitem) in tempItems.enumerated(){
            for di in jsonStringDict{
                if (tempitem.name!) == di.key{
                    print(tempitem.name!)
                    for dict in referenceDict{
                        if dict.key as!String == "\(di.value)" {
                            let result = (referenceDict.value(forKey: dict.key as!String) as![String:Any])["-displayName"]
                            self.contentlabItems.replaceObject(at: i, with: result!)
                        }
                    }
                    if !(referenceDict.allKeys as NSArray).contains("\(di.value)"){
                        self.contentlabItems.replaceObject(at: i, with: "\(di.value)")
                        if di.key == "-allocation"{
                            self.contentlabItems.replaceObject(at: i, with: jsonStringDict["costCenterName"] as!String)
                        }
                    }
                }
            }
        }
    }
    // MARK:- loadNetworkData ------
    func loadFieldDataFromNetWork() {
        // load field data
        Storage.shareStorage.expenseLineItemTemp(expenseTypeId: expenseType, needReference: false) { (resultDicArr) in
            print(resultDicArr)
            guard let str = self.CEView?.AmountTextfield.text else{
                return
            }
            let defaultConfigDic =  resultDicArr[2]["defaultConfig"] as![String:Any]
            for dict in defaultConfigDic{
                self.enpenseDefaultConfigDic.updateValue(dict.value, forKey: dict.key)
            }
            self.enpenseDefaultConfigDic.updateValue("USD \(str)", forKey: "nonPersonalNativeAmount")
            self.enpenseDefaultConfigDic.updateValue("USD \(str)", forKey: "nativeAmount")
            let metadictArr =  resultDicArr[1]["metadata"] as![[String:Any]]
            for fieldict in metadictArr{
                let item =  ExpenseFieldItem(dict: fieldict)
                if item.label == "Date" || item.label == "Amount" || item.label == "Currency" || item.label == "Note" || item.label == "Expense Type"{
                    continue
                }
                self.items.append(item)
            }
            for _ in 0..<self.items.count{
                self.contentlabItems.add("")
            }
            self.contentlabItems.replaceObject(at: 0, with: defaultConfigDic["costCenterName"] as!String)
            if self.isCcExpenseListType{
                let ccExpense = Storage.shareStorage.queryExpensesModelByEKey(eKey: self.relamExpenseClientId, applyLock: false)
                
                let jsonDict = ccExpense?.jsonString.getDictionaryFromString() as! [String:Any]
                self.handReferenceData(jsonStringDict: jsonDict, expensefieldItems: metadictArr)
            }
            self.CETView.reloadData()
        }
    }

    func loadData()  {
        enpenseDefaultConfigDic.updateValue(3500501, forKey: "currencyFormat")
        enpenseDefaultConfigDic.updateValue(expenseName, forKey: "expenseName")
        enpenseDefaultConfigDic.updateValue(expenseType, forKey: "expenseType")
        if isExpenseListType || isCcExpenseListType{ // There is a status that is edit ! and status that begin create expense has expenseName !
            guard let expenseDict = expenseModel?.jsonString.getDictionaryFromString() else{
                return
            }
            if expenseDict["expenseName"] != nil  {
                expenseName = expenseDict["expenseName"] as!String
                enpenseDefaultConfigDic.updateValue(expenseName, forKey: "expenseName")
            }
            if expenseDict["expenseType"] != nil{
                expenseType = expenseDict["expenseType"] as!Int
                enpenseDefaultConfigDic.updateValue(expenseType, forKey: "expenseType")
            }
        }
        if self.numDateStr == "" {
            if isExpenseListType || isCcExpenseListType{
                guard let expenseDict = expenseModel?.jsonString.getDictionaryFromString() else{
                    return
                }
                enpenseFielDict.updateValue(expenseDict["date"] as! String, forKey: "date")
                enpenseDefaultConfigDic.updateValue(expenseDict["date"] as! String, forKey: "date")
                self.numDateStr = expenseDict["date"] as! String
            } else {
                enpenseFielDict.updateValue(nowNormalDateString(), forKey: "date")
                enpenseDefaultConfigDic.updateValue(nowNormalDateString(), forKey: "date")
                self.numDateStr = nowNormalDateString()
            }
        }
        // get currency data  network
        Storage.shareStorage.corporData(type: "ALCurrencyFormat", finished: { [weak self](currencyItems) in
            for currency in currencyItems{
                self?.currencyArray.append(currency.displayName)
            }
            self?.currencyItems = currencyItems
        })
        
//------------------------------------------------------------------------------
        if isExpenseListType {
            isAgainPrepareDone = true
            guard let expenseModel =  expenseModel else{
                return
            }
            let jsonStringDict = expenseModel.jsonString.getDictionaryFromString()
            var expeClientId = ""
            if jsonStringDict["eKey"] != nil{
                expeClientId = jsonStringDict["eKey"] as! String
            }
            _ = Storage.shareStorage.queryExpensesModelByEKey(eKey: expeClientId, applyLock: true)
            var  exTypeId = 0
            if jsonStringDict["expenseType"] != nil{
                exTypeId = (jsonStringDict["expenseType"]) as! Int
            }
            let AmountText = (jsonStringDict["nativeAmount"] as! NSString).substring(from: 4)
            guard let CEView = CEView else{
                return
            }
            CEView.AmountTextfield.text = "\(AmountText)"
            let expensefieldItems = Storage.shareStorage.queryExpenseLineItemTempMetadataBy(expenseTypeId: exTypeId)
            let fields = expensefieldItems
            for item in fields{
                let item =  ExpenseFieldItem(dict: item)
                if item.label == "Date" || item.label == "Amount" || item.label == "Currency" || item.label == "Note" || item.label == "Expense Type"{
                    continue
                }
                self.items.append(item)
            }
            for _ in 0..<self.items.count{
                self.contentlabItems.add("")
            }
            // displayUI
            let displayUIDic = expenseModel.displayUI.getDictionaryFromString()
            let imagUrlItems = displayUIDic["imagUrlItems"] as?[String]
            if displayUIDic["imagUrlItems"] != nil && imagUrlItems!.count > 0 {
                let subStr = imagUrlItems![0]
                CEView.phoneImageView.image =  UIImage(contentsOfFile: subStr)
                CEView.currentImageV = CEView.phoneImageView
                for imageItemUrl in imagUrlItems! {
                    CEView.PhoneImages.append(UIImage(contentsOfFile: imageItemUrl)!)
                }
                CEView.PhoneCountLabel.text = "\(imagUrlItems!.count)"
            }
            if displayUIDic["contentlabItems"] != nil{
                self.contentlabItems = displayUIDic["contentlabItems"] as!NSMutableArray // Here is self-defined ExpemseType contentlabItems
            } else{
//                self.handReferenceData(jsonStringDict: jsonStringDict as![String:Any], expensefieldItems: expensefieldItems) // Here is
            }
            self.CETView.reloadData()
            if expenseModel["status"] as!String == "invalid" && jsonStringDict["error"] != nil{
                let alertView = UIAlertView(title: (jsonStringDict["error"] as!NSDictionary)["message"] as!String, message: "", delegate: self, cancelButtonTitle: "OK")
                alertView.show()
            }
        } else if isCcExpenseListType{
            isAgainPrepareDone = true
            let ccExpense = Storage.shareStorage.queryExpensesModelByEKey(eKey: self.relamExpenseClientId, applyLock: false)
            
            let jsonDict = ccExpense?.jsonString.getDictionaryFromString() as! [String:Any]
            let AmountText = (jsonDict["nativeAmount"] as! NSString).substring(from: 4)
            guard let CEView = CEView else{
                return
            }
            CEView.AmountTextfield.text = "\(AmountText)"
            loadFieldDataFromNetWork()
        } else{
             loadFieldDataFromNetWork()
        }

    }
}

extension CreatExpenseVC{
    
    func initView() {
        // CETView tableHeaderView
        CEView = Bundle.main.loadNibNamed("ExpenseMsgView", owner: nil, options: nil)?.first as? ExpenseMsgView
        guard let CEView = CEView else {
            return
        }
        CEView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH , height: 280)
        CEView.DateButton.addTarget(self, action: #selector(DateButtonClick), for: .touchUpInside)
        CEView.CurrencyButton.addTarget(self, action: #selector(CurrencyButtonClick), for: .touchUpInside)
        if isExpenseListType {
            guard let expeClientId = expenseModel?.jsonString.getDictionaryFromString()["eKey"] as? String,
                let expenseItem = Storage.shareStorage.queryExpensesModelByEKey(eKey: expeClientId, applyLock: false)
                
                else {
                    return
            }
            CEView.DateButton.setTitle(expenseItem.date, for: [])
        } else if isCcExpenseListType{
            let ccExpenselist = Storage.shareStorage.queryExpensesModelByEKey(eKey: self.relamExpenseClientId, applyLock: false)
            
            let jsonDict = ccExpenselist?.jsonString.getDictionaryFromString() as! [String:Any]
            let dateString = jsonDict["date"] as! String
            CEView.DateButton.setTitle(dateString, for: [])
        }
        view.addSubview(CETView)
        CETView.tableHeaderView = CEView
    }
    
    func DateButtonClick() {
        view.endEditing(true)
        let dateV = DatePickView(frame: CGRect(x: 0, y: -64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        dateV.myClosure = { (yearStr: String, monthStr: String , dayStr: String,numMonth:String) -> Void in
            self.CEView?.DateButton.setTitle(dayStr + " " + monthStr + ", " + yearStr, for: [])
            if Int(dayStr)! < 10{
                self.numDateStr = yearStr + "/" + numMonth + "/" + "0" + dayStr
            }else{
                self.numDateStr = yearStr + "/" + numMonth + "/" + dayStr
            }
            self.enpenseFielDict.updateValue(self.numDateStr, forKey: "date")
            self.enpenseDefaultConfigDic.updateValue(self.numDateStr, forKey: "date")
        }
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(dateV)
    }
    func CurrencyButtonClick() {
        view.endEditing(true)
        let currency = CurrencyPickView(frame: CGRect(x: 0, y: -64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        currency.currencyTypeArray = self.currencyArray
        currency.curClosure = { (provinceStr) -> Void in
            self.CEView?.CurrencyButton.setTitle(provinceStr, for: [])
        }
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(currency)
    }
    
}
//about method with keyboard
extension CreatExpenseVC:UITextFieldDelegate{

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textFieldCell =  textField.superview?.superview as! DetailMsgTVCell
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let indeRow = CETView.indexPath(for: textFieldCell)?.row else {
            return
        }
        if textField.text != "" {
        enpenseDefaultConfigDic.updateValue(textField.text!, forKey: Storage.shareStorage.queryExpenseLineItemTempFieldsNameArr(expenseTypeId: expenseType as Int)[indeRow])
        }
        let str = CEView!.AmountTextfield.text!
        if  str != textField.text {
           self.contentlabItems.replaceObject(at: indeRow, with: textField.text!)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.25, animations: {
            var frame = self.view.frame
            if SCREEN_HEIGHT == 812{
                frame.origin.y = 88
            }else{
                frame.origin.y = 64
            }
            self.view.frame = frame
        }, completion: nil)
    }
}
extension CreatExpenseVC{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll=====")
        print(CETView.frame)
    }
    func setupNavBar() {
        
        title = "Create an Expense"
        let item1 = UIBarButtonItem(title:"Cancel",style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
        navigationItem.leftBarButtonItem = item1
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let item2 = UIBarButtonItem(title:"Done",style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneClick))
        navigationItem.rightBarButtonItem = item2
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        
        if expenseModel?.status == "Done" {// can't be editing
            navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func cancelClick() {
       
      
        if isExpenseListType {
            let expeClientId = expenseModel?.jsonString.getDictionaryFromString()["eKey"] as! String
            _ = Storage.shareStorage.queryExpensesModelByEKey(eKey: expeClientId, applyLock: false)
            navigationController?.popViewController(animated: true)
            return
        }
        if isCcExpenseListType{
            guard let CEView = CEView else {
                return
            }
            let str =  NSString(string:CEView.AmountTextfield.text!)
           postNotificationName(name: "updateMyExpenseListData", andUserInfo: ["AllocationsMoney":Float(str.floatValue)])
        }
        popToRootExpenseViewController()
    }
    
    // save operation
    func doneClick() {
        view.endEditing(true)
        displayUIDic.updateValue(contentlabItems, forKey: "contentlabItems")
        guard let CEView = CEView else {
            return
        }
        let str =  NSString(string:CEView.AmountTextfield.text!)
        if str == "" || str == "0"{
            SVProgressHUD.showError(withStatus: "please write in amount !")
            return
        }
        if CEView.PhoneImages.count > 0 {
            displayUIDic.updateValue(CEView.photoUrlItems, forKey: "imagUrlItems")
        }
        if isAgainPrepareDone { // to draft expenseModel prepare done ，no matter how AmountTextfield.text changed
            guard let expenseModel = expenseModel,
                let expeClientId = expenseModel.jsonString.getDictionaryFromString()["eKey"] as? String,
                let expenseItem = Storage.shareStorage.queryExpensesModelByEKey(eKey: expeClientId, applyLock: false),
            
                var expenseDict = expenseItem.jsonString.getDictionaryFromString() as?[String:Any]
                else {
                    return
            }
            print(expenseDict)
            print(enpenseDefaultConfigDic)
//            for edict in expenseDict {
                for eDefdict in enpenseDefaultConfigDic {
//                    if edict.key == eDefdict.key {
//                        print(edict.key)
//                        expenseDict.updateValue(eDefdict.value, forKey: edict.key)
//                    } else {
//                        print("+" + eDefdict.key,eDefdict.value)
                        expenseDict.updateValue(eDefdict.value, forKey: eDefdict.key)
//                        expenseDict.updateValue(edict.value, forKey: edict.key)
//                    }
//                      break
                }
//            }
            print(expenseDict)
            if isCcExpenseListType{
                let displayUIDic = ["displayUI":self.displayUIDic.getJSONStringFromDictionary()]
                Storage.shareStorage.updateExpensesModelWithEKey(eKey: expeClientId, andExpenseDict: displayUIDic)
            }else{
                var displayDic = expenseItem.displayUI.getDictionaryFromString() as![String:Any]
                for dic  in displayDic{
                    if dic.key == "contentlabItems"{
                        displayDic.updateValue(self.contentlabItems, forKey: dic.key)
                    }
                }
                let displayUIDic = ["displayUI":displayDic.getJSONStringFromDictionary()]
                Storage.shareStorage.updateExpensesModelWithEKey(eKey: expeClientId, andExpenseDict: displayUIDic)
            }
            let tempDict = ["jsonString":expenseDict.getJSONStringFromDictionary(),"date":self.numDateStr,"status":"draft"]
            Storage.shareStorage.updateExpensesModelWithEKey(eKey: expeClientId, andExpenseDict: tempDict)
            SVProgressHUD.showSuccess(withStatus: "Fix Successful!")
            postNotificationName(name: "updateMyExpenseListData", andUserInfo: ["AllocationsMoney":Float(str.floatValue)])
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.popToRootExpenseViewController()
            }
            return
        }
        
        let clientEkey = Storage.shareStorage.takeEKey()
        enpenseFielDict.updateValue(clientEkey, forKey: "eKey")
        enpenseDefaultConfigDic.updateValue(clientEkey, forKey: "eKey")
        let enpenseDefaultConfigStr = enpenseDefaultConfigDic.getJSONStringFromDictionary()
        enpenseFielDict.updateValue(enpenseDefaultConfigStr, forKey: "jsonString")
        print(enpenseDefaultConfigDic)
        let displayUIStr = displayUIDic.getJSONStringFromDictionary()
        enpenseFielDict.updateValue(displayUIStr, forKey: "displayUI")
        print(enpenseFielDict)
        Storage.shareStorage.saveExpense(expenseDict: enpenseFielDict, releaseLock: false)
        UserDefaults.standard.set(clientEkey, forKey: "eKey")
        // post a notification, demand update total money
        postNotificationName(name: "updateMyExpenseListData", andUserInfo: ["isUpdateOneExpense":true])
        // give a reminder,and return
        SVProgressHUD.showSuccess(withStatus: "Save Successful!")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.popToRootExpenseViewController()
        }
    }
    
    
}

extension CreatExpenseVC{
    
    func calcurateAllocationAmounts(AmountTotal:Float,alloAmounts:NSMutableArray){
        var totalRes:Float = 0.0
        for (i,amount) in alloAmounts.enumerated() {
            let value = String(Float(amount as! String)! / AmountTotal)
            percentArray.append(Float(value)!)
            let result =  Float(CEView!.AmountTextfield.text!)!
            if i == alloAmounts.count - 1 { // endIndex
                let res = result - totalRes
                alloAmounts.replaceObject(at: i, with: String(format:"%.2f%", Float(res)))
                break
            }
            let amountResult =  String(format:"%.2f%", Float(result * percentArray[i]))
            totalRes += Float(amountResult)!
            alloAmounts.replaceObject(at: i, with: "\(amountResult)")
        }
    }
    
    func setNotificationObserver(){
        // add notification
        addNotificationObserver(name: "WriteDoneNotification")
        addNotificationObserver(name: "LocationNotification")
        addNotificationObserver(name: NSNotification.Name.UIKeyboardWillShow.rawValue)
        addNotificationObserver(name: NSNotification.Name.UIKeyboardWillHide.rawValue)
    }
    override func handleNotification(notification: NSNotification) {
        guard let CEView = CEView else {
            return
        }
        switch notification.name {
        case Notification.Name(rawValue: "WriteDoneNotification"):
            let userInfo = notification.userInfo as! [String: AnyObject]
            if userInfo["text"] as? String == "" {
                return
            }
            CEView.AddNoteLabel.text = userInfo["text"] as? String
            enpenseDefaultConfigDic.updateValue(CEView.AddNoteLabel.text!, forKey: "-note")
        case Notification.Name(rawValue: "LocationNotification"):
            let userInfo = notification.userInfo as! [String: AnyObject]
            guard self.contentlabItems.count > 0
                else {
                    print("contentlabItems为空")
                    return
            }
            self.contentlabItems.replaceObject(at: indexPathRow, with: userInfo["totalStr"] as! String)
            let nameArr =  Storage.shareStorage.queryExpenseLineItemTempFieldsNameArr(expenseTypeId: expenseType)
            enpenseDefaultConfigDic.updateValue(userInfo["id"] as! Int, forKey: nameArr[indexPathRow])
            CETView.reloadData()
        case NSNotification.Name.UIKeyboardWillShow:
            let userinfo: NSDictionary = notification.userInfo! as NSDictionary
            let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
            let keyboardRec = (nsValue as AnyObject).cgRectValue
            let height = keyboardRec?.size.height
            if CEView.AmountTextfield.isEditing || isClickCell{ //if it responsed method of AmountTextfield ,don't run following method
                return
            }
            UIView.animate(withDuration: 0, animations: {
                var frame = self.view.frame
                if SCREEN_HEIGHT - (self.textFieldCell.y - self.CETView.contentOffset.y + 64) < height!{
                    frame.origin.y = -height! + 64
                }else{
                    if SCREEN_HEIGHT
                        - height! - (self.textFieldCell.y - self.CETView.contentOffset.y + 64) < 65{
                        frame.origin.y = -30
                    }
                }
                self.view.frame = frame
            }, completion: nil)
        case NSNotification.Name.UIKeyboardWillHide:
            if CEView.AmountTextfield.isEditing { //if it responsed method of AmountTextfield ,don't run following method
                let str =  NSString(string:CEView.AmountTextfield.text!)
                if  str != "" {
                    enpenseDefaultConfigDic.updateValue("USD \(str)", forKey: "nativeAmount")
                }else{
                    return
                }
                for exDic in enpenseDefaultConfigDic{
                    if exDic.key == "-allocation"{
                       let dicArr = enpenseDefaultConfigDic["-allocation"] as![[String:Any]]
                      
                        var  tempDicArr = [[String:Any]]()
                        for var dic in dicArr{
                            let result = (dic["percentage"] as!Float)*(Float(str as String)!)
                            dic.updateValue("USD \(result)", forKey: "nativeAmount")
                            tempDicArr.append(dic)
                        }
                        enpenseDefaultConfigDic.updateValue(tempDicArr, forKey: "-allocation")
                    }
                }
                print(enpenseDefaultConfigDic)
            }
            print("UIKeyboardWillHide")
        default:
            print("==")
        }
    }
}

extension CreatExpenseVC:AllocationsItemsDelegate{
    func AllocationsReturnWithItems(allocations: [CorpDataModel],colorStrItems: [String], amountItems: NSMutableArray, subPerLabGFrameItems: [String],isDSAllocation:Bool,pencentItems:[Float]) {
        isExpenseListType = false
        allocationAmounts = amountItems
        allocationColorStrItems = colorStrItems
        subPerLabFrameStrItems = subPerLabGFrameItems
        isDataSAllocation = isDSAllocation
        percentArray = pencentItems
        if CEView?.AmountTextfield.text == "0" {
            CEView?.AmountTextfield.text = nil
        }
            var displayNameStr = ""
            if allocations.count == 1{
                displayNameStr += allocations.first!.displayName
            } else if allocations.count > 1{
                displayNameStr += allocations.first!.displayName + ",..."
            }
            allocationCostCenters = allocations
            // judge allocations amount and add allocations
            var allocationDicts = [[String:Any]]()
            for costCenter in allocationCostCenters {
                var allocationDic = [String:Any]()
                if costCenter.jsonString.getDictionaryFromString()["type"] as!Int == 29500  {
                    allocationDic.updateValue(costCenter.uid, forKey: "costCenterName")
                } else if costCenter.jsonString.getDictionaryFromString()["type"] as!Int == 80000{
                    allocationDic.updateValue(costCenter.uid, forKey: "projectNumber")
                }
                allocationDicts.append(allocationDic)
            }
            for i in 0..<allocationDicts.count {
                allocationDicts[i].updateValue("USD " + (allocationAmounts[i] as!String), forKey: "nativeAmount")
                allocationDicts[i].updateValue(percentArray[i], forKey: "percentage")
            }
            enpenseDefaultConfigDic.updateValue(allocationDicts, forKey: "-allocation")
            self.contentlabItems.replaceObject(at: indexPathRow, with: displayNameStr)
            // add contentlabItems
            if contentlabItems.count > 0 {
                displayUIDic.updateValue(contentlabItems, forKey: "contentlabItems")
            }
            displayUIDic.updateValue(allocationAmounts, forKey: "allocationAmounts")
            var alloCSDics = [[String:Any]]()
            if allocationCostCenters.count > 0 {
                alloCSDics =  CorpDataModel.model2NSDictionaryWith(allocationCostCenters)
            }
            displayUIDic.updateValue(alloCSDics, forKey: "alloCSDics")
            displayUIDic.updateValue(allocationColorStrItems, forKey: "allocationColorStrItems")
            displayUIDic.updateValue(subPerLabFrameStrItems, forKey: "subPerLabFrameStrItems")
            CETView.reloadData()
//        }
    }
    
    // MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.scrollViewDidEndDecelerating(tableView)
      
        indexPathRow = indexPath.row
        let field = items[indexPath.row]
        if field.type == "boolean"{
            let cell = tableView.cellForRow(at: indexPath) as!DetailMsgTVCell
            cell.isClick = !cell.isClick
            cell.checkImageV.image = UIImage(named: cell.isClick ? "checked" : "unchecked")
            self.contentlabItems.replaceObject(at: indexPath.row, with: cell.isClick ? "1" : "0")
            return
        }
        if field.type == "time" || field.type == "int" || field.type == "decimal" || field.type == "string"{
            return
        }
        if items[indexPath.row].type == "allocation" {
           let handallo =  HandAllocationTool()
           handallo.handAllocationWith(item: items[indexPath.row], subVC: self, expenseMo: expenseModel ?? ExpensesModel())
            return
        }
        let addEx = AddExpenseTypeVC()
        if field.bySearch != nil {
            isClickCell = true
            addEx.bySearch = field.bySearch!
        }
        if field.type != nil {
            addEx.type = field.type!
        }
        addEx.title = items[indexPath.row].label
        addEx.expenseType = expenseType
        navigationController?.pushViewController(addEx, animated: true)
    }
    
    // MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailMsgTVCell")! as! DetailMsgTVCell
        var typeString = ""
        if items[indexPath.row].type != nil{
            typeString = items[indexPath.row].type!
        }
        if  typeString == "string" || typeString == "decimal" || typeString == "int"{
            cell.contentfield.delegate = self;
            cell.contentfield.text = self.contentlabItems[indexPath.row] as? String
        } else if typeString == "boolean"{
            if self.contentlabItems[indexPath.row] as? String == "1"{
                  cell.checkImageV?.image = UIImage(named: "checked")
            } else{
                  cell.checkImageV?.image = UIImage(named: "unchecked")
            }
        } else if typeString == "time"{
                let ges =  UITapGestureRecognizer(target: self, action: #selector(gesTap))
                cell.contentLabel.isUserInteractionEnabled = true
                cell.contentLabel.addGestureRecognizer(ges)
        }
        cell.contentLabel.text = self.contentlabItems[indexPath.row] as? String
        cell.expenseFieldM = items[indexPath.row]
        DetailMsgTVCellItems.append(cell)
        return cell
    }
    
    func gesTap(tapges:UIGestureRecognizer) {
        let tiPicView = TimePickView(frame: CGRect(x: 0, y: -64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        tiPicView.tiClosure = { timestr in
            (tapges.view as!UILabel).text = timestr
        }
        self.view.addSubview(tiPicView)
    }
}


