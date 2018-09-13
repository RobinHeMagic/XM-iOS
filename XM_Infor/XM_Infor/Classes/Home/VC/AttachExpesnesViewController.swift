//
//  AttachExpesnesViewController.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class AttachExpesnesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var allExpensesBtn: UIButton!
    @IBOutlet weak var allExpensesLabel: UILabel!
    @IBOutlet weak var allExpensesImageView: UIImageView!
    @IBOutlet weak var allExpensesView: UIView!

    @IBOutlet weak var outOfPocketBtn: UIButton!
    @IBOutlet weak var outOfPocketLabel: UILabel!
    @IBOutlet weak var outOfPocketImageView: UIImageView!
    @IBOutlet weak var outOfPocketView: UIView!
    
    @IBOutlet weak var corporateCardBtn: UIButton!
    @IBOutlet weak var corporateCardLabel: UILabel!
    @IBOutlet weak var corporateCardImageView: UIImageView!
    @IBOutlet weak var corporateCardView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewForNoContent: UIView!
    
    /// Xib widgets array
    var switchBtnArr: Array<UIButton> = []
    var switchLabelArr: Array<UILabel> = []
    var switchImageViewArr: Array<UIImageView> = []
    var switchViewArr: Array<UIView> = []
    
    /// DataSource
    var dataSourceArr: Results<ExpensesModel>!
    var dataSoruceArr_group: Array<Array<ExpensesModel>> = []
    var dateArr: Array<String> = []
    
    /// Selected Expenses
    var selectedExpenses: Array<ExpensesModel> = []
    
    /// Value from last ViewController
    var  expenseReportEKey = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// NavigationBar Cofig
        title = "Attach Expenses"
        
        let leftBarBtnItem = UIBarButtonItem (title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelCreateExpenseReport))
        leftBarBtnItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftBarBtnItem

        let rightBarBtnItem = UIBarButtonItem (title: "Submit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(attachAndSummitBarBtnItem))
        rightBarBtnItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightBarBtnItem
        
        /// Set Arrays
        switchBtnArr.append(allExpensesBtn)
        switchBtnArr.append(outOfPocketBtn)
        switchBtnArr.append(corporateCardBtn)
        
        switchLabelArr.append(allExpensesLabel)
        switchLabelArr.append(outOfPocketLabel)
        switchLabelArr.append(corporateCardLabel)
        
        switchImageViewArr.append(allExpensesImageView)
        switchImageViewArr.append(outOfPocketImageView)
        switchImageViewArr.append(corporateCardImageView)
        
        switchViewArr.append(allExpensesView)
        switchViewArr.append(outOfPocketView)
        switchViewArr.append(corporateCardView)

        /// Gradient color
        let gradientLayer = getGradientColorGradientLayer(w: 375, h: 300, view: headerView)
        headerView.layer.insertSublayer(gradientLayer, at: 0)
        
        /// Set DataSource
        dataSourceArr = Storage.shareStorage.queryExpensesModelByStatus(status: "valid")
        groupingDataSources()
        viewForNoContentIsHiddenOrNot()
        
        /// TableView Cofig
        tableView.register(UINib (nibName: "CommonlyExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "commonlyExpensesReportCell")
//        self.edgesForExtendedLayout = .bottom
        // Do any additional setup after loading the view.
    }
    
    func viewForNoContentIsHiddenOrNot() {
        
        if dataSourceArr.count == 0 {
            viewForNoContent.isHidden = false
        }else{
            viewForNoContent.isHidden = true
        }
    }
    
    func groupingDataSources() {
        /// Clear data source.
        dateArr.removeAll()
        dataSoruceArr_group.removeAll()
        selectedExpenses.removeAll()
        
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
    
    func cancelCreateExpenseReport() {
        
        if expenseReportEKey != "" {
            Storage.shareStorage.deleteExpenseReportModel(eKey: expenseReportEKey)
        }
        
        self.popToRootExpenseViewController()
    }
    
    func attachAndSummitBarBtnItem() {
        
        if selectedExpenses.count == 0 {
            SVProgressHUD.showError(withStatus: "Choose at least one.")
            SVProgressHUD.dismiss(withDelay: 0.8)
        }else{
            var expenseLineItem: Array<[String: Any]> = []
            var lineItemEKeyArr: Array<String> = []
            
            for item in selectedExpenses {
                // Append line item json and line item client id.
                let expenseDict = item.jsonString.getDictionaryFromString() as! [String: Any]
                expenseLineItem.append(expenseDict)
                lineItemEKeyArr.append(item.eKey)
                
                // Update Realm
                try! XMRealm.write {
                    item.superEKey = expenseReportEKey
                }
                
                Storage.shareStorage.saveOrUpdateData(model: item)
                
            }
            var expenseReportDict: [String: Any] = Storage.shareStorage.queryExpenseReportModel(eKey: expenseReportEKey).jsonString.getDictionaryFromString() as! [String: Any]
            
            expenseReportDict.merge(dict: ["-lineItems": expenseLineItem])
            print(expenseReportDict)
            Storage.shareStorage.expenseReport(postMode: "submit", lineItemEKeyArr: lineItemEKeyArr, expenseReport: expenseReportDict, finished: { (isSuccess) in
                
                if isSuccess as? String == "success" {
                    NotificationCenter.default.post(name: NSNotification.Name (rawValue: "updateMyExpenseListData"), object: self, userInfo: nil)
                    self.popToRootExpenseViewController()
                    
                }else if let brvArr = isSuccess as? Array<[String: Any]> {
                    var stringArr: Array<String> = []
                    var string = ""
                    
                    for item in brvArr {
                        if item["businessRuleInteractMesg"] == nil {
                            stringArr.append("No Interact Message !")
                            continue
                        }
                        stringArr.append(item["businessRuleInteractMesg"] as! String)
                    }
                    
                    if stringArr.count <= 1 {
                        string = stringArr[0]
                    }else{
                        
                        for (index, item) in stringArr.enumerated().reversed() {
                            stringArr[index] = "\(index + 1)." + item + "\n"
                            string = stringArr[index] + string
                        }
                    }
                    
                    self.showAlert(string: string)
                    
                }else if let errorDict = (isSuccess as? [String: Any]) {
                    if errorDict["code"] != nil {
                        self.showAlert(string: errorDict["message"] as! String)
                    }
                }
            })
        }
    }
    
    func showAlert(string: String) {
        let alert = UIAlertController.init(title: "Business Rule Violation", message: string, preferredStyle: .alert)
        let okAction = UIAlertAction (title: "OK", style: .default, handler: nil)

        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func allExpesnesBtnAction(_ sender: UIButton) {
        if sender.isSelected == true {
            
        }else{
            /// Set buttons state
            for (_, button) in switchBtnArr.enumerated() {
                button.isSelected = false
            }
            sender.isSelected = true
            
            /// Set labels color
            for (_, label) in switchLabelArr.enumerated() {
                label.textColor = UIColor.white
            }
            allExpensesLabel.textColor = UIColor .colorWithRGB(62, g: 130, b: 189)
            
            /// Set imageViews' image
            outOfPocketImageView.image = UIImage (named: "outOfPocket_white")
            corporateCardImageView.image = UIImage (named: "card_white")
            allExpensesImageView.image = UIImage (named: "expenses_azure")
            
            /// Set views background color
            for (_, view) in switchViewArr.enumerated() {
                view.backgroundColor = UIColor.clear
                view.alpha = 1
            }
            
            allExpensesView.backgroundColor = UIColor.white
            allExpensesView.alpha = 0.5
            // Change data source and reload data
            dataSourceArr = Storage.shareStorage.queryExpensesModelByStatus(status: "valid")
            groupingDataSources()
            tableView.reloadData()
        }
    }
    
    @IBAction func outOfPocketBtnAction(_ sender: UIButton) {
        if sender.isSelected == true {
            
        }else{
            /// Set buttons state
            for (_, button) in switchBtnArr.enumerated() {
                button.isSelected = false
            }
            sender.isSelected = true
            
            /// Set labels color
            for (_, label) in switchLabelArr.enumerated() {
                label.textColor = UIColor.white
            }
            outOfPocketLabel.textColor = UIColor .colorWithRGB(62, g: 130, b: 189)
            
            /// Set imageViews' image
            outOfPocketImageView.image = UIImage (named: "outOfPocket_azure")
            corporateCardImageView.image = UIImage (named: "card_white")
            allExpensesImageView.image = UIImage (named: "expenses_white")
            
            /// Set views background color
            for (_, view) in switchViewArr.enumerated() {
                view.backgroundColor = UIColor.clear
                view.alpha = 1
            }
            
            outOfPocketView.backgroundColor = UIColor.white
            outOfPocketView.alpha = 0.5
            // Change data source and reload data
            dataSourceArr =  Storage.shareStorage.queryOutOfPocketExpensesModelBy(status: "valid")
            groupingDataSources()
            tableView.reloadData()
        }
    }
    
    @IBAction func corporateCardBtnAction(_ sender: UIButton) {

        if sender.isSelected == true {
            
        }else{
            /// Set buttons state
            for (_, button) in switchBtnArr.enumerated() {
                button.isSelected = false
            }
            sender.isSelected = true
            
            /// Set labels color
            for (_, label) in switchLabelArr.enumerated() {
                label.textColor = UIColor.white
            }
            corporateCardLabel.textColor = UIColor .colorWithRGB(62, g: 130, b: 189)
            
            /// Set imageViews' image
            outOfPocketImageView.image = UIImage (named: "outOfPocket_white")
            corporateCardImageView.image = UIImage (named: "card_azure")
            allExpensesImageView.image = UIImage (named: "expenses_white")
            
            /// Set views background color
            for (_, view) in switchViewArr.enumerated() {
                view.backgroundColor = UIColor.clear
                view.alpha = 1
            }
            
            corporateCardView.backgroundColor = UIColor.white
            corporateCardView.alpha = 0.5
            // Change data source and reload data
            dataSourceArr = Storage.shareStorage.queryCorporateCardExpenseModelBy(status: "valid")
            groupingDataSources()
            tableView.reloadData()
        }
    }
    
    ///*************************TableViewDelegate************************
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSoruceArr_group.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSoruceArr_group[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    ///*************************TableViewDataSource************************

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "commonlyExpensesReportCell"
        
        var cell: CommonlyExpensesTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CommonlyExpensesTableViewCell
        
        if cell.isEqual(nil) {
            cell = CommonlyExpensesTableViewCell (style: .default, reuseIdentifier: identifier)
        }
        
        let model = (dataSoruceArr_group[indexPath.section])[indexPath.row]
    
        cell.checkBox.isHidden = false
        cell.expenseModel = model
        cell.checkBox.image = UIImage (named: "unchecked")
        cell.internalView.borderWidth = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Change UI
        let cell: CommonlyExpensesTableViewCell = tableView.cellForRow(at: indexPath) as! CommonlyExpensesTableViewCell
        cell.checkBox.image = UIImage (named: "checked")
        cell.internalView.borderWidth = 1
        
        /// Change data
        let expenseModel: ExpensesModel = (dataSoruceArr_group[indexPath.section])[indexPath.row]
        selectedExpenses.append(expenseModel)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        /// Change UI
        let cell: CommonlyExpensesTableViewCell = tableView.cellForRow(at: indexPath) as! CommonlyExpensesTableViewCell
        cell.checkBox.image = UIImage (named: "unchecked")
        cell.internalView.borderWidth = 0
        
        /// Change data
        let expenseModel: ExpensesModel = (dataSoruceArr_group[indexPath.section])[indexPath.row]
        
        for (index, item) in selectedExpenses.enumerated() {
            if item.eKey == expenseModel.eKey{
                selectedExpenses.remove(at: index)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dateArr[section]
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
