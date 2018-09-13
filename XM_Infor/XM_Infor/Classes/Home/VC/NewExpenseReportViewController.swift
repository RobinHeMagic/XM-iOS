//
//  NewExpenseReportViewController.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD

class NewExpenseReportViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: Array<[String: Any]> = []           //Table view data source.
    
    var contentlabItems = NSMutableArray()                  //The subtitles on the right side of the cell.
    
    var textFieldDict: [String: String] = ["title": ""]     //All text field information, default title is empty.
    
    var textFieldCell = DetailMsgTVCell()                   //Some cell that has text field.
    
    var headerInfor: [String: Any] = [:]                    //Expense report header information.
    
    var indexPathRow: Int = 0                               //The number of rows of cells selected.
    
    var fieldNames: [String] = []                           //Expense report fields.
    
    var isExisted: Bool = false                             /*true:Show a existed expense report;
                                                             false: Show a nonexistent expense report.*/
    
    var isFillIn = true                                     //All required fields are filled in or not.

    var purposeId = 0
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.

        super.viewDidLoad()
        
        navigationBarConfig()
        
        getExpenseReportFormNetwork()
        
        addNotificationObserver(name: "LocationNotification")
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldUpdate(notif:)), name: NSNotification.Name (rawValue: "postTextOftextFieldDidChanged"), object: nil)
        
        tableView.tableFooterView = UIView()
}
    
    func textFieldUpdate(notif: NSNotification) {
        
        let cell = notif.object as! DetailMsgTVCell
        guard let rowOfCell = tableView.indexPath(for: cell)?.row else {
            return
        }
        let key = (dataSource[rowOfCell])["name"] as! String
        
        headerInfor.updateValue(cell.contentfield.text!, forKey: key)

    }
    
    func navigationBarConfig() {
        
        title = "New Expense Report"
        
        let leftBarBtnItem = UIBarButtonItem (title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(popViewController))
        leftBarBtnItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftBarBtnItem
        
        let rightBarBtnItem = UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.plain, target: self, action: #selector(createExpenseReport))
        rightBarBtnItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightBarBtnItem
        
    }

    /// Create an ExpenseReport to store to the Realm and send its eKey to the next page.
    func createExpenseReport() {
        
        /// Check all required fields are filled out.
        for (index,item) in dataSource.enumerated() {
            
            let jsonStrDict = item
            if Array(jsonStrDict.keys).contains("required"){
                let isRequired: Bool = jsonStrDict["required"] as! Bool
                if isRequired{
                    var names: Array<String> = []
                    for item in dataSource {
                        names.append(item["name"] as! String)
                    }
                    
                    switch headerInfor[names[index]] {
                        
                    case let str as String:
                        
                        if str == "" {
                            
                            isFillIn = false
                            print("headerInfor[names[index]] is empty string ")
                            
                        }else{
                            
                            print("headerInfor[names[index]] is string ", headerInfor[names[index]] as! String)
                            
                        }
                        
                    case is Int: break
                        
                    default:
                        
                        isFillIn = false
                        
                    }
                }
            }
        }

        let expenseReportEkey = Storage.shareStorage.createExpenseReportWithInformation(infor: headerInfor)
        
//        var dict: [String : Any] = Storage.shareStorage.queryExpenseReportModel(clientId: expenseReportEkey).read()
        var dict: [String: Any] = Storage.shareStorage.queryExpenseReportModel(eKey: expenseReportEkey).read()
        
        dict.removeValue(forKey: "createDate")
        
        if isFillIn {
            
            let viewController = AttachExpesnesViewController()
            
            viewController.expenseReportEKey = expenseReportEkey
            
            navigationController?.pushViewController(viewController, animated: true)
 
        }else{
            
            SVProgressHUD.showError(withStatus: "Check all required fields, please.")
            SVProgressHUD.dismiss(withDelay: 0.8)
            
            isFillIn = true
        }
    }

    func getExpenseReportFormNetwork() {
        Storage.shareStorage.expenseReportTemp(purpose: purposeId) { (result) in
            self.fieldNames = Storage.shareStorage.queryExpenseReportFormFieldBy(purposeId: self.purposeId, fieldName: "label")
            let expenseReportFormArr = Storage.shareStorage.queryExpenseReportFormArrayBy(purposeId: self.purposeId)
            self.dataSource = expenseReportFormArr
            
            for _ in self.dataSource {
                self.contentlabItems.add("")
            }
            /// TableView Config
            self.tableView.register(UINib.init(nibName: "DetailMsgTVCell", bundle:nil), forCellReuseIdentifier: "DetailMsgTVCell")
            self.tableView.reloadData()
        }
    }
    
    override func handleNotification(notification: NSNotification) {
        
        guard let infor = notification.userInfo else {
            return
        }
        
        contentlabItems.replaceObject(at: indexPathRow, with: infor["totalStr"] as!String)
        headerInfor.updateValue(infor["id"] ?? 0, forKey: Storage.shareStorage.queryExpenseReportFormFieldBy(purposeId: purposeId, fieldName: "name")[indexPathRow])
        if let purpose = headerInfor["purpose"] {
            purposeId = purpose as! Int
        }
        getExpenseReportFormNetwork()
        tableView.reloadData()
    }

    
    /// Recovery of the keyboard
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        view.endEditing(true)
        
    }
    
    //********************UITableViewDelegate**********************
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        indexPathRow = indexPath.row
        
        let cell: DetailMsgTVCell = tableView.cellForRow(at: indexPath) as! DetailMsgTVCell
        
        if cell.contentfield.isHidden == false {
            
        }
        
        let dict = dataSource[indexPath.row]
        
        if dict["bySearch"] != nil {
            
            let addExpenseTypeVC = AddExpenseTypeVC()
            
            addExpenseTypeVC.bySearch = 1
            
            navigationController?.pushViewController(addExpenseTypeVC, animated: true)
            
        }else{
            if dict["type"] as! String == "corpData" {
                let addExpenseTypeVC = AddExpenseTypeVC()
                addExpenseTypeVC.bySearch = 0
                addExpenseTypeVC.type = dict["label"] as! String
                navigationController?.pushViewController(addExpenseTypeVC, animated: true)
            }
        }
        
    }
    
    //********************UITableViewDataSource********************

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "DetailMsgTVCell")! as! DetailMsgTVCell
        
        if cell.isEqual(nil) {
            cell = DetailMsgTVCell (style: .default, reuseIdentifier: "DetailMsgTVCell")
        }

        
        if  dataSource[indexPath.row]["type"] as! String == "string" || dataSource[indexPath.row]["type"] as! String == "bigdecimal"{
            
            cell.contentfield.isHidden = false
            cell.contentLabel.isHidden = true
            cell.arrowImageView.isHidden = true
            cell.contentfield.delegate = self;
            
            if dataSource[indexPath.row]["type"] as! String == "bigdecimal" {
                cell.contentfield.keyboardType = UIKeyboardType.decimalPad
            }
            
        }else{
            
            cell.contentfield.isHidden = true
            cell.contentLabel.isHidden = false
            cell.arrowImageView.isHidden = false
            cell.contentfield.keyboardType = UIKeyboardType.default
            
        }
        
        if dataSource[indexPath.row]["required"] == nil{
            
            cell.markLabel.isHidden = true
            
        }else{
            
            cell.markLabel.isHidden = false
            
        }
        
        cell.selectionStyle = .none
        
        cell.MsgName.text = dataSource[indexPath.row]["label"] as? String
        cell.contentLabel.text = self.contentlabItems[indexPath.row] as? String
        cell.tag = 100 + indexPath.row
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
