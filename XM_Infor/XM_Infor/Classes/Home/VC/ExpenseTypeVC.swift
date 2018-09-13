//
//  ExpenseTypeVC.swift
//  XM_Infor
//
//  Created by Robin He on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
class ExpenseTypeVC: XMBaseViewController {

    var expenseTypeTabView:UITableView?
   
    var expenseTypeArray = [CorpDataModel]()
    var expenseReport:ExpenseReportModel?
    var erModelDict:[String:Any]?
    var isclickCreat = false
    var superClientId = 0
    var status = ""
    var jsonstring = ""
    
    var expenseReportdict = [String: Any]()

    var relamClientId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Expense Type"
        view.backgroundColor = UIColor.white
        setNav()
        loadData()
       
        setupUI()
        
        print("1")
        print("2")
    }
   
    func loadData(){
        Storage.shareStorage.corporData(type: "ExpenseType", finished: { [weak self](expenseItems) in
            if expenseItems.count > 0 { //
                self?.expenseTypeArray = expenseItems
                self?.expenseTypeTabView?.reloadData()
            }
        })
    }
    
    func setNav(){
        let item1 = UIBarButtonItem(title:"Back",style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
        navigationItem.leftBarButtonItem = item1
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        print("大大的改写了代码")
    }
    
    func cancelClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        expenseTypeTabView = UITableView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), style: .plain)
        expenseTypeTabView?.delegate = self
        expenseTypeTabView?.dataSource = self
        expenseTypeTabView?.register(UINib.init(nibName: "expenseTypeTabCell", bundle: nil), forCellReuseIdentifier: "expenseTypeTabCell")

        // expenseTypeTabCell
        expenseTypeTabView?.separatorStyle = .none
        view.addSubview(expenseTypeTabView!)
    }
}

extension ExpenseTypeVC:UITableViewDataSource,UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = CreatExpenseVC()
        vc.expenseName = expenseTypeArray[indexPath.row].displayName
        vc.expenseType = expenseTypeArray[indexPath.row].uid
        vc.superClientId = superClientId
        if self.relamClientId != "" {
            guard  let expense = Storage.shareStorage.queryExpensesModelByEKey(eKey: self.relamClientId, applyLock: false) else {
                return
            }
            var jsonStringDict = expense.jsonString.getDictionaryFromString() as! [String: Any]
            let  expenseType = expenseTypeArray[indexPath.row].uid
            jsonStringDict.updateValue(expenseType, forKey: "expenseType")
            jsonStringDict.updateValue(vc.expenseName, forKey: "expenseName")
            vc.isCcExpenseListType = true
            vc.relamExpenseClientId = self.relamClientId
            vc.expenseModel = expense
            let tempDict = ["jsonString":jsonStringDict.getJSONStringFromDictionary()]
            Storage.shareStorage.updateExpensesModelWithEKey(eKey: self.relamClientId, andExpenseDict: tempDict)
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 55
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose Expense Type"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseTypeTabCell") as! expenseTypeTabCell
        cell.expenseTypeNameLabel.text = (expenseTypeArray[indexPath.row] as CorpDataModel).displayName
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenseTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           cell.layer.transform = CATransform3DMakeScale(0.75, 0.75, 075)
        UIView.animate(withDuration: 0.25) {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
}
