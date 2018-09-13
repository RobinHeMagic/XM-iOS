//
//  ExpenseRepoerDetailViewController.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift

class ExpenseRepoerDetailViewController: HaveFloatBallBaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pushBtn: UIButton!
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var expenseReportTitleTF: UITextField!

    @IBOutlet weak var receiptsAttachedValueLabel: UILabel!
    
    @IBOutlet weak var chargeCodesValueLabel: UILabel!
    
    @IBOutlet weak var createdDateValueLabel: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewForNoContent: UIView!
    
    var totalAmount:Double = 0.00
    
    /// Value from last ViewController
    var expenseReportEKey = ""
    
    /// DataSource
    var dataSourceArr: Results<ExpensesModel>!
    var dataSoruceArr_group: Array<Array<ExpensesModel>> = []
    var dateArr: Array<String> = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let expenseReportModel = Storage.shareStorage.queryExpenseReportModel(eKey: expenseReportEKey)
        let expenseReportJSONStringDict: [String: Any] = expenseReportModel.jsonString.getDictionaryFromString() as! [String: Any]
        
        
        ///Receive the value of the previous page
        expenseReportTitleTF.text = expenseReportJSONStringDict["title"] as? String
        expenseReportTitleTF.isUserInteractionEnabled = false
        
        /// NavigationBar Cofig
        title = "Expense Report"
        
//        let rightBarBtnItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveBarBtnAction))
//        rightBarBtnItem.tintColor = UIColor.white
//        navigationItem.rightBarButtonItem = rightBarBtnItem
        
        let leftBarBtnItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToHomeVC))
        leftBarBtnItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftBarBtnItem
        
        /// Gradient color
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.colorWithHexString("006699").cgColor, UIColor.colorWithHexString("339966").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: headerView.bounds.height/SCREEN_HEIGHT)
        gradientLayer.frame = headerView.bounds
        self.headerView.layer.insertSublayer(gradientLayer, at: 0)
        
        /// Set DataSource
        dataSourceArr = Storage.shareStorage.queryExpensesModelBySuperEKey(superEKey: expenseReportEKey)
        CalculateTheTotalAmount()
        groupingDataSources()
        
        /// Set headerView and view for no content
        receiptsAttachedValueLabel.text = "\(dataSourceArr.count)"
        createdDateValueLabel.text = dateStringToEnglish(date: expenseReportModel.createDate)
        viewForNoContentIsHiddenOrNot()
        
        /// TableView config
        tableView.register(UINib (nibName: "CommonlyExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "commonlyExpensesReportCell")

        NotificationCenter.default.addObserver(self, selector: #selector(tableViewReload), name: NSNotification.Name (rawValue: "reloadTableView"), object: nil)
        
        // Do any additional setup after loading the view.
        
    }
    
    func tableViewReload() {
        
        totalAmount = 0
        dataSoruceArr_group.removeAll()
        viewDidLoad()
        
        tableView.reloadData()
        
    }
    
    func viewForNoContentIsHiddenOrNot() {
        
        if dataSourceArr.count == 0 {
            
            viewForNoContent.isHidden = false
            
        }else{
            
            viewForNoContent.isHidden = true
            
        }
        
    }
    
    @IBAction func popToViewController(_ sender: UIButton) {
        
        popViewController()
        
    }

    func CalculateTheTotalAmount() {
        
        totalAmount = 0
        
        for item in dataSourceArr {
            
            let dict: [String: Any] = item.jsonString.getDictionaryFromString() as! [String: Any]
            totalAmount = totalAmount + ((dict["nativeAmount"] as![String:Any])["amount"] as! Double)
            
        }
        
        totalAmountLabel.text = String (format: "$%.2f", totalAmount)

    }
    
    
    func groupingDataSources() {
        
        /// Put all dates in dateArr
        for item in dataSourceArr {
            
            if !dateArr.contains(item.date) {
                dateArr.append(item.date)
            }
            
        }
        
        dateArr.sort(by: >)
        
        /// Create empty array for
        for _ in dateArr {
            
            let arr: [ExpensesModel] = []
            dataSoruceArr_group.append(arr)
            
        }
        
        for item in dataSourceArr {
            
            for date in dateArr {
                
                if item.date == date {
                    
                    ((dataSoruceArr_group[dateArr.index(of: date)!])).append(item)
                    
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /// Recovery of the keyboard
        if !expenseReportTitleTF.isExclusiveTouch {
            expenseReportTitleTF.resignFirstResponder()
        }
        
    }
    
    func backToHomeVC() {
        
        self.navigationController?.popToRootViewController(animated: true)
        postNotificationName(name: "updateExpenseReportData", andUserInfo: [:])
    }
    
    func saveBarBtnAction() {

        backToHomeVC()

    }

    
    ///**************UITableViewSourceData******************

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identify: String = "commonlyExpensesReportCell"
        var cell: CommonlyExpensesTableViewCell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath) as! CommonlyExpensesTableViewCell
        
        if cell.isEqual(nil) {
            cell = CommonlyExpensesTableViewCell (style: .default, reuseIdentifier: identify)
        }
        
        let model = (dataSoruceArr_group[indexPath.section])[indexPath.row]
//        let dict: [String: Any] = model.jsonString.getDictionaryFromString() as! [String : Any]
//        
//        cell.expenseTypeLabel.text = dict["expenseName"]! as? String
//        cell.amountLabel.text = String (format: "$%.2f", dict["nativeAmount"] as! Double)
        cell.expenseModel = model
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        return dataSoruceArr_group[section].count
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataSoruceArr_group.count
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return dateArr[section]
    }
    
    ///**************UITableViewDelegate********************
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 180
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !expenseReportTitleTF.isExclusiveTouch {
            expenseReportTitleTF.resignFirstResponder()
        }
        
        let createExpenseVC = CreatExpenseVC()
        navigationController?.pushViewController(createExpenseVC, animated: true)
//        createExpenseVC.jsonString = dataSoruceArr_group[indexPath.section][indexPath.row].jsonString
        createExpenseVC.isExpenseListType = true
        createExpenseVC.previousIndexRow = indexPath.row
        
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        
//        let expenseModel = self.dataSoruceArr_group[indexPath.section][indexPath.row]
//        
//        let delete = UITableViewRowAction (style: .default, title: "DELETE") { (action, index) in
//            
//            Storage.shareStorage.deleteExpensesModel(eKey: expenseModel.eKey)
//            
//            handleTableViewDisplay()
//            
//        }
//        delete.backgroundColor = UIColor.red
//        
//        let deAttach = UITableViewRowAction (style: .normal, title: "DEATTACH") { (action, index) in
//            
//            
//            try! XMRealm.write {
//                
//                expenseModel.superEKey = 0
//            }
//            
//            handleTableViewDisplay()
//            
//        }
//        
//        func handleTableViewDisplay() {
//            
//            self.dataSoruceArr_group[indexPath.section].remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            self.receiptsAttachedValueLabel.text = "\(self.dataSourceArr.count)"
//            
//            
//            if self.dataSoruceArr_group[indexPath.section].count == 0 {
//                self.dateArr.remove(at: indexPath.section)
//                self.dataSoruceArr_group.remove(at: indexPath.section)
//                
//            }
//            
//            self.CalculateTheTotalAmount()
//            
//            /// TODO: If use reloadData, delete animate will disapper
//            tableView.reloadData()
//            self.viewForNoContentIsHiddenOrNot()
//            
//        }
//        return [delete, deAttach]
//        
//
//        
//    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//    }
    
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
