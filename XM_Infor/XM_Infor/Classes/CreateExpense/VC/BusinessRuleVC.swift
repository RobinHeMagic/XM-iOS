//
//  BusinessRuleVC.swift
//  XM_Infor
//
//  Created by Robin He on 20/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
class BusinessRuleVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var violationTableView:UITableView?
    var businessRuleViolations = [BusinessRuleViolationModel]()
    var warningViolations = [BusinessRuleViolationModel]()
    var explanationViolations = [BusinessRuleViolationModel]()
    var invalidViolations = [BusinessRuleViolationModel]()

    var expenseModel:ExpensesModel?

    var warnIndexPath:IndexPath?
    var explanationPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        guard let expenModel = expenseModel else {
            return
        }
        let jsonStrDict = expenModel.jsonString.getDictionaryFromString()
    
//        automaticallyAdjustsScrollViewInsets = false
        if jsonStrDict["-brv"] == nil {
            SVProgressHUD.showInfo(withStatus: "Not BIV at the present moment.")
            return
        }
        initView()
        let jsonViolations =  jsonStrDict["-brv"] as! [[String: Any]]
        for jsonDic in jsonViolations {
            businessRuleViolations.append(BusinessRuleViolationModel(dict: jsonDic))
        }
        for ruleViolation in businessRuleViolations {
            if ruleViolation.businessRuleSeverity == 2 {
             warningViolations.append(ruleViolation)
            
            }else if ruleViolation.businessRuleSeverity == 1{
            
            explanationViolations.append(ruleViolation)
            }else {
            
              invalidViolations.append(ruleViolation)
            
            }
            
        }
    
        setupNav()
    }
    
    func setupNav() {
        title = "VIOLATIONS"
        
        let dict:NSDictionary = [NSForegroundColorAttributeName: UIColor.white,NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18)]
     
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [String : AnyObject]
        
        let item1 = UIBarButtonItem(title:"Cancel",style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
        
        navigationItem.leftBarButtonItem = item1
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let item2 = UIBarButtonItem(title:"Save",style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveClick))
        
        navigationItem.rightBarButtonItem = item2
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white

        if invalidViolations != [] {
            if invalidViolations.count > 0 && explanationViolations.count == 0 && warningViolations.count == 0{
                navigationItem.rightBarButtonItem?.isEnabled = false
                navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
            }
        }
        
        if self.explanationViolations != [] {
          
            if self.explanationViolations[0].explanation  != nil {
                navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
        
        if self.warningViolations != [] {
            if self.warningViolations[0].userAccept == 1 {
            
                navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
                navigationItem.rightBarButtonItem?.isEnabled = false

            }
        }
       
        
    }
    func initView() {
        
        violationTableView = UITableView(frame: view.bounds, style: .plain)
        violationTableView?.delegate = self
        violationTableView?.dataSource = self
        violationTableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
        violationTableView?.scrollIndicatorInsets = violationTableView!.contentInset
        violationTableView?.register(UINib.init(nibName: "BusinessRuleWarningCell", bundle:nil), forCellReuseIdentifier: "BusinessRuleWarningCell")
        violationTableView?.register(UINib.init(nibName: "BusinessRuleExplenlationCell", bundle:nil), forCellReuseIdentifier: "BusinessRuleExplenlationCell")
        violationTableView?.register(UINib.init(nibName: "BusinessRuleInvaildCell", bundle:nil), forCellReuseIdentifier: "BusinessRuleInvaildCell")
        
         view.addSubview(violationTableView!)
    }
    func cancelClick() {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func saveClick() {
    
        /// warning
        var WarningCell = BusinessRuleWarningCell()
        var explanationCell = BusinessRuleExplenlationCell()
        for i in 0..<warningViolations.count {
           WarningCell = violationTableView?.cellForRow(at: [warnIndexPath!.section,i]) as!BusinessRuleWarningCell
            if !WarningCell.ConfirmButton.isSelected {
                SVProgressHUD.showInfo(withStatus: "Please confirm warning !")
                return
            }
        }
        for i in 0..<explanationViolations.count {
            explanationCell = violationTableView?.cellForRow(at: [explanationPath!.section,i]) as!BusinessRuleExplenlationCell
            if explanationCell.explanationTextView.text == "" {
                SVProgressHUD.showInfo(withStatus: "Please write in explanation !")
                return
            }
        }
        SVProgressHUD.showSuccess(withStatus: "Save successfully!")
        let BRVDicts = expenseModel?.jsonString.getDictionaryFromString()["-brv"] as! [[String: Any]]
        var brvDicts = [[String: Any]]()
        for brvDict in BRVDicts {
            var brvD = brvDict
            if brvDict["businessRuleSeverity"] as! Int == 2 {
                brvD.updateValue(1, forKey: "userAccept")
            } else if brvDict["businessRuleSeverity"] as! Int == 1{
                brvD.updateValue(explanationCell.explanationTextView.text, forKey: "explanation")
            }
            brvDicts.append(brvD)
        }
       
        guard  let expense = Storage.shareStorage.queryExpensesModelByEKey(eKey: expenseModel!.eKey, applyLock: false) else {
            return
        }
        
       var jsonStringDict = expense.jsonString.getDictionaryFromString() as! [String: Any]
        jsonStringDict.updateValue(brvDicts, forKey: "-brv")
       
        var statusMsg = ""
        if invalidViolations.count > 0 {
            statusMsg = "invalid"
        } else {
            statusMsg = "valid"
        }
        let tempDict = ["jsonString":jsonStringDict.getJSONStringFromDictionary(),"status":statusMsg]
        Storage.shareStorage.updateExpensesModelWithEKey(eKey: (expenseModel?.eKey)!, andExpenseDict: tempDict)
        
        postNotificationName(name: "updateMyExpenseListData", andUserInfo: [:])
        navigationController?.popViewController(animated: true)
        
    }
}

extension BusinessRuleVC{

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            
            if explanationViolations.count > 0 && invalidViolations.count == 0 && warningViolations.count == 0{
                return "explanations"
            } else if invalidViolations.count > 0 && explanationViolations.count == 0 && warningViolations.count == 0{
                return "invalids"
            }

            return "warnings"
        case 1:
          
            if invalidViolations.count > 0 && explanationViolations.count == 0{
                return "invalids"
            }
            
            return "explanations"
        case 2:
            return "invalids"
        default:
            print("")
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if indexPath.section == 0 {
            
            
            if warningViolations.count == 0 && explanationViolations.count > 0 && invalidViolations.count == 0{
               
                let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRuleExplenlationCell") as! BusinessRuleExplenlationCell
                
                
                cell.expBRVModel = explanationViolations[indexPath.row]
                
                
                explanationPath = indexPath
                
                cell.selectionStyle = .none
                return cell

            
            } else if warningViolations.count == 0 && explanationViolations.count == 0 && invalidViolations.count > 0 {
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRuleInvaildCell") as! BusinessRuleInvaildCell
                
                cell.MessageLabel.text = invalidViolations[indexPath.row].businessRuleInteractMesg
                cell.PolicyLabel.text = invalidViolations[indexPath.row].businessRulePolicy
                
                cell.selectionStyle = .none
                return cell
            
            }else{
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRuleWarningCell") as! BusinessRuleWarningCell
                
                cell.BRVModel = warningViolations[indexPath.row]
                
                cell.selectionStyle = .none
                warnIndexPath = indexPath
                return cell

            }
            
        } else if indexPath.section == 1{
            
            
            if invalidViolations.count > 0 && explanationViolations.count == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRuleInvaildCell") as! BusinessRuleInvaildCell
                
                cell.MessageLabel.text = invalidViolations[indexPath.row].businessRuleInteractMesg
                cell.PolicyLabel.text = invalidViolations[indexPath.row].businessRulePolicy
                cell.selectionStyle = .none
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRuleExplenlationCell") as! BusinessRuleExplenlationCell
          
            
            cell.expBRVModel = explanationViolations[indexPath.row]
            

            explanationPath = indexPath
            
            cell.selectionStyle = .none
            return cell
        
        } else {
           
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessRuleInvaildCell") as! BusinessRuleInvaildCell
            
            cell.MessageLabel.text = invalidViolations[indexPath.row].businessRuleInteractMesg
            cell.PolicyLabel.text = invalidViolations[indexPath.row].businessRulePolicy
           
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return 250

        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if warningViolations.count != 0 && explanationViolations.count != 0 && invalidViolations.count != 0 {
            return 3
       
        } else if warningViolations.count != 0 && explanationViolations.count != 0{
        
          return 2
       
        } else if warningViolations.count != 0 && invalidViolations.count != 0{
            
            return 2
        } else if explanationViolations.count != 0 && invalidViolations.count != 0{
            
            return 2
        } else if explanationViolations.count != 0 || invalidViolations.count != 0 || warningViolations.count != 0 {
            
            return 1
        }

        return 0
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            if explanationViolations.count > 0 && invalidViolations.count == 0 && warningViolations.count == 0 {
                return explanationViolations.count
            } else if invalidViolations.count > 0 && explanationViolations.count == 0 && warningViolations.count == 0 {
               return invalidViolations.count
            
            }
             return warningViolations.count
        } else if section == 1 {
          
            if self.invalidViolations.count > 0 && self.explanationViolations.count == 0{
                return invalidViolations.count
            }
            
         return explanationViolations.count
        } else {
         return invalidViolations.count
        }
    }

}
