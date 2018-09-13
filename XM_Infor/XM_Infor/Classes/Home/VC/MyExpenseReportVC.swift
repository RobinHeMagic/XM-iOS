//
//  MyExpenseReportVC.swift
//  XM_Infor
//
//  Created by Robin He on 25/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
enum ExpensesListType {
    case ExpensesListTypeAll
    case ExpensesListTypePocket
    case ExpensesListTypeCreditCard
}
class MyExpenseReportVC: HaveFloatBallBaseVC,UITableViewDelegate,UITableViewDataSource {

    var MyExpenseReportTableView:UITableView?
    
    var expenseReportItems:Results<ExpenseReportModel>?
    var expenseRealmItems:Results<ExpensesModel>?
    
    var indexRow:Int?
    var timeResults = [String]()
    var newExpenseResults = [[ExpensesModel]]()
    var pocketExpenses = [[ExpensesModel]]()
    var creditCardExpenses = [[ExpensesModel]]()
    var expensesTag = 1
    
    var outExpenseResults = [[[String:Any]]]() // out of pocket
    var corpRateExpenseResults = [[[String:Any]]]() // corprate Card
    var tagExpenseResults = [[[String:Any]]]()
    var errorExpenseMsgLab:UILabel?
    var errorERMsgLab:UILabel?
    
    var isNotiUpdateCell = false
    
    
    fileprivate lazy var reportTableView:UITableView = {

        let reportTableV = UITableView()
        reportTableV.separatorStyle = .none
        reportTableV.backgroundColor = UIColor.colorWithRGB(245, g: 246, b: 248)
        reportTableV.register(UINib.init(nibName: "DraftReportsTabCell", bundle: nil), forCellReuseIdentifier: "DraftReportsTabCell")
        reportTableV.delegate = self
        reportTableV.dataSource = self
        reportTableV.frame = CGRect(x: 0, y: 115, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 180)
        reportTableV.isHidden = true
        self.view.addSubview(reportTableV)
        
        return reportTableV
        
    }()
 
    fileprivate lazy var expensesTabv:UITableView = {
    
        let expenTav = UITableView()
       
        expenTav.separatorStyle = .none
        expenTav.backgroundColor = UIColor.colorWithRGB(245, g: 246, b: 248)
        expenTav.register(UINib.init(nibName: "CommonlyExpensesTableViewCell", bundle: nil), forCellReuseIdentifier: "commonlyExpensesReportCell")
        expenTav.delegate = self
        expenTav.dataSource = self
        expenTav.frame = CGRect(x: 0, y: 235, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 300)
        expenTav.isHidden = false
        self.view.addSubview(expenTav)
        
        return expenTav
    }()
    
    
    var isExpensesTabV = true
    
    override func viewDidLoad() {
    
        isHome = true
        super.viewDidLoad()
        setNav()
        initView()
        initNetWorkDataFromRealm()
        ExpenseReportSingleTon.shareSingleTon.networkManager?.startListening()

        addNotificationObserver(name: "updateMyExpenseListData")
        addNotificationObserver(name: "updateExpenseReportData")
        addNotificationObserver(name: "uploadReceiptNoti")
    }
    deinit {
        ExpenseReportSingleTon.shareSingleTon.timerStop()
         NotificationCenter.default.removeObserver(self)
    }
}

extension  MyExpenseReportVC{
    override func viewWillDisappear(_ animated: Bool) {
        let fball = FloatingBall.shared
        fball.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        let fball = FloatingBall.shared
        fball.isHidden = false
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    /// Ergodic ExpenseListDic
    ///
    /// - Parameter dictItems: dictItems
    /// - Returns: [[[ExpensesModel]]]
    
    func ErgodicExpenseListDictWithType(dictItems:[ExpensesModel]) -> [[ExpensesModel]] {
        
        var dateStr = ""
        var AllExpenseItems = [[ExpensesModel]]()
        var EXDateItems = [String]()
            for expense in dictItems{
                dateStr = expense.date
                if EXDateItems != [] && EXDateItems.contains(dateStr) {
                    continue
                }
                EXDateItems.append(dateStr)
            }
            for exDate in EXDateItems {
                var expenItems = [ExpensesModel]()
                for expense in dictItems{
                    if exDate == expense.date {
                        expenItems.append(expense)
                    }
                }
                AllExpenseItems.append(expenItems)
            }
        print(AllExpenseItems)
        return AllExpenseItems

    }

    func initData() {
    
        expenseRealmItems = Storage.shareStorage.queryAllExpenseModels()
        var expenseErgodicRealmItems = [ExpensesModel]()
        for item in expenseRealmItems! {
            expenseErgodicRealmItems.append(item)
        }
        loadExpensesDataWith(ExpenseList: expenseErgodicRealmItems, ExpenListType: .ExpensesListTypeAll)
  //=================================================
        self.creditCardExpenses.removeAll()
        self.pocketExpenses.removeAll()
        var ccardExpenses = [ExpensesModel]()
        var poExpenses = [ExpensesModel]()
        
        for ExpenseResults in self.newExpenseResults {
            for expense in ExpenseResults{
                if expense.jsonString.getDictionaryFromString()["ccTransactionId"] != nil{
                    ccardExpenses.append(expense)
                }else{
                    poExpenses.append(expense)
                }
            }
        }
  //==========================================
        loadExpensesDataWith(ExpenseList: ccardExpenses, ExpenListType: .ExpensesListTypeCreditCard)
        loadExpensesDataWith(ExpenseList: poExpenses, ExpenListType: .ExpensesListTypePocket)
        
        errorExpenseMsgLab?.isHidden = expenseRealmItems?.count != 0
        expenseReportItems = Storage.shareStorage.queryAllExpenseReports()
    }

    func loadExpensesDataWith(ExpenseList:[ExpensesModel],ExpenListType:ExpensesListType) {
         var ExpenseResults = [[ExpensesModel]]()
        let ExResults = ErgodicExpenseListDictWithType(dictItems: ExpenseList)
        for item in ExResults{
            ExpenseResults.append(item)
            switch ExpenListType {
            case .ExpensesListTypeAll:
                 newExpenseResults.append([ExpensesModel()])
            case .ExpensesListTypePocket:
                 pocketExpenses.append([ExpensesModel()])
            case .ExpensesListTypeCreditCard:
                 creditCardExpenses.append([ExpensesModel()])
            }
        }
        var timeArr = [String]()
        for (_,ExpenseItem) in ExpenseResults.enumerated() {
            timeArr.append(ExpenseItem[0].date)
        }
        for (i,time) in timeBecomeString(timeStringItems: timeArr).enumerated() {
            for expense in ExpenseResults {
                if time == expense[0].date {
                    switch ExpenListType {
                    case .ExpensesListTypeAll:
                        newExpenseResults.replaceSubrange(i..<i+1, with: [expense])
                    case .ExpensesListTypePocket:
                          pocketExpenses.replaceSubrange(i..<i+1, with: [expense])
                    case .ExpensesListTypeCreditCard:
                        creditCardExpenses.replaceSubrange(i..<i+1, with: [expense])
                    }
                }
            }
        }
    }
    
    func initNetWorkDataFromRealm(){
        self.expenseRealmItems = Storage.shareStorage.queryAllExpenseModels()
        if self.expenseRealmItems?.count == 0 {
            Storage.shareStorage.ccExpenseLineItem(isReference: true) {[weak self] expenseModels in
                print(expenseModels)
                self?.initData()
                self?.postNotificationName(name: "expenseRealmItemsFromNetworkNoti", andUserInfo: [:])
               self?.expensesTabv.reloadData()
            }
        }else{
            initData()
        }
        
    }
    override func handleNotification(notification: NSNotification) {
        switch notification.name {
        case Notification.Name(rawValue: "updateMyExpenseListData"):
            if notification.userInfo?["isUpdateOneExpense"] != nil{
             isNotiUpdateCell = notification.userInfo?["isUpdateOneExpense"] as! Bool
            }
            newExpenseResults = []
            initData()
            expensesTabv.reloadData()
        case Notification.Name(rawValue: "updateExpenseReportData"):
            reportTableView.reloadData()
        case Notification.Name(rawValue:"uploadReceiptNoti"):
            UIApplication.shared.keyWindow?.rootViewController?.view?.addSubview(reminderLabel())
        default:
            print("")
        }
    }
        
    func setNav() {
        title = "Expenses"
         UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
//        navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navigationBarBG"), for: .default)
        let dict:NSDictionary = [NSForegroundColorAttributeName: UIColor.white,NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18)]
        
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [String : AnyObject]
        view.backgroundColor = UIColor.white
        
        
        let item1 = UIBarButtonItem(title:"Back",style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
        navigationItem.leftBarButtonItem = item1
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
    }
    
    func nextClick() {
        
        navigationController?.pushViewController(CreatExpenseVC(), animated: true)
    }
    override func cancelClick(){
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func initView() {
        let headerView = MyExpenseReportHeaderView.XMExpenseReportHeaderView()
        headerView.frame = CGRect(x: 0, y: -64, width: SCREEN_WIDTH, height: 305)
        headerView.delegate = self
        view.addSubview(headerView)
        
        headerView.expenseAllButtonV.btnClosure = {[weak self] tag in
            self?.expensesTag = tag
           
            self?.expensesTabv.reloadData()
        }
        view.addSubview(expensesTabv)
        view.addSubview(reportTableView)
        
    
        errorExpenseMsgLab = UILabel(frame: CGRect(x: 40, y: getLength(leng: 365), width: SCREEN_WIDTH - 80, height: 65))
        errorExpenseMsgLab?.text = "There is no ExpenseList now, Please create some Expenses !"
        errorExpenseMsgLab?.numberOfLines = 0
        errorExpenseMsgLab?.textAlignment = .center
        view.addSubview(errorExpenseMsgLab!)
       
        errorERMsgLab = UILabel()
        errorERMsgLab?.text = "There is no ER now, Please create some ExpenseRepoorts !"
        errorERMsgLab?.bounds = CGRect(x: 0, y: 0, width: 295, height: 65)
        errorERMsgLab?.center = self.view.center
        errorERMsgLab?.numberOfLines = 0
        errorERMsgLab?.textAlignment = .center
        errorERMsgLab?.isHidden = true
        view.addSubview(errorERMsgLab!)
    }
  
}


extension MyExpenseReportVC:MyExpenseReportHeaderViewDelegate{
  
    func MyExpenseReportHeaderViewWithJudge(isExpense: Bool) {
        
        if isExpense {
            
            expensesTabv.isHidden = false
            reportTableView.isHidden = true
            
            errorERMsgLab?.isHidden = true
            errorExpenseMsgLab?.isHidden = expenseRealmItems?.count != 0
            
        } else {
            reportTableView.isHidden = false
            expensesTabv.isHidden = true
            errorExpenseMsgLab?.isHidden = true
            errorERMsgLab?.isHidden = expenseReportItems?.count != 0
            
        }
    }
}

extension  MyExpenseReportVC{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == expensesTabv {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commonlyExpensesReportCell") as! CommonlyExpensesTableViewCell
            cell.checkBox.isHidden = true
            if expensesTag == 1{
                cell.expenseModel = newExpenseResults[indexPath.section][indexPath.row]
            }else if expensesTag == 2{
                 cell.expenseModel = pocketExpenses[indexPath.section][indexPath.row]
            }else{
                 cell.expenseModel = creditCardExpenses[indexPath.section][indexPath.row]
            }
            guard let expenseModel =  Storage.shareStorage.queryAllExpenseModels().last
                else {
                    return cell
            }
            if isNotiUpdateCell && expenseModel == cell.expenseModel{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    UIView.animate(withDuration: 1.0, animations: {
                        cell.internalView.borderWidth = 1
                        cell.internalView.borderColor = UIColor.green
                    }, completion: { (_) in
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                            cell.internalView.borderWidth = 1
                            cell.internalView.borderColor = UIColor.white
                        })
                    })
                }
                isNotiUpdateCell = false
            }
            return cell
  
        } else if tableView == reportTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DraftReportsTabCell") as! DraftReportsTabCell
            cell.expenseReportItem = expenseReportItems?[indexPath.row]
            return cell
        }
        return UITableViewCell()
       
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.colorWithRGB(245, g: 246, b: 248)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == expensesTabv  {
            return 50
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == expensesTabv {
            
            if expensesTag == 1{
                if newExpenseResults[section].count > 0 {
                    return newExpenseResults[section][0].date
                }
            }else if expensesTag == 2{
                if pocketExpenses[section].count > 0 {
                    return pocketExpenses[section][0].date
                }
            }else if expensesTag == 3{
                if creditCardExpenses[section].count > 0{
                    return creditCardExpenses[section][0].date
                }
            }
            return ""
        }
        return ""
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == expensesTabv {
            return 120
        } else {
           return 200
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == expensesTabv  {
            if expensesTag == 2{
              return pocketExpenses[section].count
            }else if expensesTag == 3{
              return creditCardExpenses[section].count
            }
              return newExpenseResults[section].count
        }else{
          return 0
        }
      
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        if tableView == expensesTabv {
            if expensesTag == 2{
                return pocketExpenses.count
            }else if expensesTag == 3{
                return creditCardExpenses.count
            }
             return newExpenseResults.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if tableView == expensesTabv {
            if newExpenseResults[indexPath.section][indexPath.row].jsonString.getDictionaryFromString()["expenseType"] == nil{
              let vc =  ExpenseTypeVC()
               let clientId = newExpenseResults[indexPath.section][indexPath.row].eKey
                vc.relamClientId = clientId
                SVProgressHUD.showInfo(withStatus: "please select an ExpenseType !")
                navigationController?.pushViewController(vc, animated: true)
                return
            } else if newExpenseResults[indexPath.section][indexPath.row].jsonString.getDictionaryFromString()["expenseType"] != nil{
                 let vc = CreatExpenseVC()
                vc.isExpenseListType = true
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            if newExpenseResults[indexPath.section][indexPath.row].jsonString.getDictionaryFromString()["-brv"] == nil{
                let vc = CreatExpenseVC()
                switch self.expensesTag {
                case 1:
                    vc.expenseModel = newExpenseResults[indexPath.section][indexPath.row]
                case 2:
                    vc.expenseModel = pocketExpenses[indexPath.section][indexPath.row]
                case 3:
                    vc.expenseModel = creditCardExpenses[indexPath.section][indexPath.row]
                default:
                    print("")
                }
                vc.isExpenseListType = true
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            let homeCellView = HomeCellClickView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), originY: self.view.center.y + 60)
            homeCellView.jsonString = newExpenseResults[indexPath.section][indexPath.row].jsonString
            homeCellView.expenseModel = newExpenseResults[indexPath.section][indexPath.row]
            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(homeCellView)
            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(homeCellView.cellHelpTabv!)
        } else {
            let vc = ExpenseRepoerDetailViewController()
             expenseReportItems = Storage.shareStorage.queryAllExpenseReports()
            vc.expenseReportEKey = (expenseReportItems?[indexPath.row].eKey)!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle{
        
        let status = newExpenseResults[indexPath.section][indexPath.row].status
        if status == "done" {
            return .none
        }
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == expensesTabv {
            if editingStyle == .delete {
                let expenseModel =  newExpenseResults[indexPath.section][indexPath.row]
              
                newExpenseResults[indexPath.section].remove(at: indexPath.row)
                if expenseModel.jsonString.getDictionaryFromString()["-reference"] != nil{
                   
                    creditCardExpenses[indexPath.section].remove(at: indexPath.row)
                }else{
                    pocketExpenses[indexPath.section].remove(at: indexPath.row)
                }
               
            
                print(creditCardExpenses)
                if newExpenseResults[indexPath.section].count == 0 {
                     newExpenseResults.remove(at: indexPath.section)
                  if expenseModel.jsonString.getDictionaryFromString()["-reference"] != nil{
                    creditCardExpenses.remove(at: indexPath.section)
                  }else{
                     pocketExpenses.remove(at: indexPath.section)
                    }
                    tableView.deleteSections(NSIndexSet(index: indexPath.section) as IndexSet, with: UITableViewRowAnimation.fade)
                } else {
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                }
                tableView.reloadData()
                Storage.shareStorage.deleteExpensesModel(eKey: expenseModel.eKey)
            }

        } else  {
        
            if editingStyle == .delete {

            }
        }
    }
}

class reminderLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.text = "Upload receipt successfully!"
        self.textAlignment = .center
        self.backgroundColor = UIColor.yellow
        self.x = 0
        self.y = -40
        self.width = SCREEN_WIDTH
        self.height = 40
        UIView.animate(withDuration: 2.0, animations: {
            self.y = 0
        }, completion: { (bo) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                UIView.animate(withDuration: 2.0, animations: {
                    self.y = -40
                })
            })
        })
        UserDefaults.standard.set(nil, forKey: "receiptDict")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
