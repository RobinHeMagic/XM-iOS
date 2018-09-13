//
//  ExpenseListVC.swift
//  XM_Infor
//
//  Created by Robin He on 05/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
import RealmSwift
class ExpenseListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var elTableView:UITableView?

    var totalMoney:Float = 0.0
    var superClitId = 0
    var corpDataTOMList:Results<ExpensesModel>?
    var businessRuleCallback:((Int)->())?
    
    var elmsgV:ELMsgView?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initView()
        
        if superClitId != 0 {
            corpDataTOMList = XMRealm.objects(ExpensesModel.self).filter("superClientId = %@", superClitId)
        }
        
        addNotificationObserver(name: "AllocationsMoneyChange")
        
    }
    
    deinit {
        removeNotificationObserver()
    }

}
extension ExpenseListVC{

    override func handleNotification(notification: NSNotification) {
      
        elmsgV?.totalAmountLabel.text = "$ \(notification.userInfo?["AllocationsMoney"] as! Float)"
        elTableView?.reloadData()
    }
}

extension ExpenseListVC{
    
    func initView() {
        
        title = "Expenses"

        let dict:NSDictionary = [NSForegroundColorAttributeName: UIColor.white,NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18)]
       
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [String : AnyObject]
        
        let item1=UIBarButtonItem(image:UIImage(named:"left46"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(showPrevious))
        self.navigationItem.leftBarButtonItem = item1
        
        elmsgV = ELMsgView.elmsgView()
        elmsgV?.totalAmountLabel.text = "$ \(totalMoney)"
        elmsgV?.frame = CGRect(x:0,y:0,width:SCREEN_WIDTH,height:getLength(leng: 220))
        view.addSubview(elmsgV!)
        
        elTableView = UITableView(frame:CGRect(x:0,y:getLength(leng: 156),width:SCREEN_WIDTH,height:SCREEN_HEIGHT - 254))
        elTableView?.delegate = self
        elTableView?.dataSource = self
        elTableView?.rowHeight = 120
        elTableView?.register(UINib.init(nibName:"ELMsgTVCell",bundle:nil), forCellReuseIdentifier: "ELMsgTVCell")
        view.addSubview(elTableView!)
    }
    
    func showPrevious() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return corpDataTOMList!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var erStatus = ""
        if superClitId == 0 {
            
            superClitId = corpDataTOMList![indexPath.row].superClientId
        }
        let expenseReportItem = XMRealm.objects(ExpenseReportModel.self).filter("clientId = %@", superClitId)
        erStatus = expenseReportItem[0].status
        guard let  jsonStr = corpDataTOMList?[indexPath.row].jsonString
           else {
            print("jsonString is nil")
            return
        }

        let vc = CreatExpenseVC()
        vc.jsonString = jsonStr
        vc.isExpenseListType = true
        vc.erStatus = erStatus
        vc.superClientId = superClitId
        vc.previousIndexRow = indexPath.row
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ELMsgTVCell")! as! ELMsgTVCell
        cell.selectionStyle = .none
        cell.expenseName.text = corpDataTOMList?[indexPath.row].jsonString.getDictionaryFromString()["expenseName"] as? String ?? ""
//
       let amountString = NSString(string:"\(String(describing: corpDataTOMList?[indexPath.row].jsonString.getDictionaryFromString()["amount"] ?? 0))") as String
//
//       var currencySymbol = corpDataTOMList?[indexPath.row].currencySymbol
//        if var currencySymbol == "" {
//            currencySymbol = "$"
//        }
        cell.expenseMoney.text = "$ \(amountString)"
        
        return cell
        
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
         let expenseReportItem = XMRealm.objects(ExpenseReportModel.self).filter("clientId = %@", superClitId)
        
        if expenseReportItem[0].status == "draft" {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
           let corp = corpDataTOMList?[indexPath.row]
           totalMoney = totalMoney - (corp?.jsonString.getDictionaryFromString()["amount"] as! Float)
            // delete XMRealm's object
             try! XMRealm.write{
              XMRealm.delete(corp!)
            }
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            elmsgV?.totalAmountLabel.text = "$ \(totalMoney)"
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "ExpenseListTotalAmountDecrease"), object: nil, userInfo: ["RestExpenseListMoney":totalMoney])
        }
    }
    

}

