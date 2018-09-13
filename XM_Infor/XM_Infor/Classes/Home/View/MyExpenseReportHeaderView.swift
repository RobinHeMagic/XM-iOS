//
//  MyExpenseReportHeaderView1.swift
//  XM_Infor
//
//  Created by Robin He on 31/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift
@objc
protocol MyExpenseReportHeaderViewDelegate:NSObjectProtocol {
    
    @objc optional func MyExpenseReportHeaderViewWithJudge(isExpense:Bool)
    
}

class MyExpenseReportHeaderView: UIView {

    @IBOutlet weak var reportsTotalAmountLabel: UILabel!
    @IBOutlet weak var expensesTotalAmountLabel: UILabel!
    @IBOutlet weak var firstButtontView: UIView!
    @IBOutlet weak var secondButtonView: UIView!
    @IBOutlet weak var expenseAllButtonV: ExpenseAllButtonView!
    @IBOutlet weak var refineLabel: UILabel!
    @IBOutlet weak var firstViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondViewWidthConstraint: NSLayoutConstraint!
    
//    var isExpenses = false
    
    weak var delegate:MyExpenseReportHeaderViewDelegate?
    class  func XMExpenseReportHeaderView() -> MyExpenseReportHeaderView {
        let nib = UINib(nibName: "MyExpenseReportHeaderView", bundle: nil)
        let v = nib.instantiate(withOwner: nib, options: nil)[0] as! MyExpenseReportHeaderView
        v.frame = UIScreen.main.bounds
//        v.backgroundColor = UIColor.init(patternImage: UIImage(named: "purper")!)
        v.layer.insertSublayer(getGradientColorGradientLayer(w: 375, h: 300, view: v), at: 0)
        
        return v
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstButtontView.backgroundColor = UIColor.lightGray
        if SCREEN_WIDTH == 320 {
            firstViewWidthConstraint.constant = 130
            secondViewWidthConstraint.constant = 130
        }
        let  tap1 = UITapGestureRecognizer()
        tap1.addTarget(self, action: #selector(tapClick1))
        firstButtontView.addGestureRecognizer(tap1)
        let  tap2 = UITapGestureRecognizer()
        tap2.addTarget(self, action: #selector(tapClick2))
        secondButtonView.addGestureRecognizer(tap2)
        
         addNotificationObserver(name: "updateMyExpenseListData")
         addNotificationObserver(name: "updateExpenseReportData")
        
        let ExpensesRealms = Storage.shareStorage.queryAllExpenseModels()
        if ExpensesRealms.count != 0 {
            var ExpenseTotalAmount:Float = 0.0
            for expense in ExpensesRealms {
                let amonut = (expense.jsonString.getDictionaryFromString()["nativeAmount"] as! NSString).substring(from: 4)
                ExpenseTotalAmount += Float(amonut)!
            }
            expensesTotalAmountLabel.text = "$ \(ExpenseTotalAmount)"
        } else {
            addNotificationObserver(name: "expenseRealmItemsFromNetworkNoti")
        }
       
        
//        let ExpenseReportRealms = Storage.shareStorage.queryAllExpenseReports()
//        var ERTotalAmounts:Float = 0.0
//        for ER in ExpenseReportRealms {
//            let expensesRealms = Storage.shareStorage.queryExpensesModelBySuperClientId(superEKey: ER.eKey)
//            for expense in expensesRealms {
//
//            }
//        }
//        reportsTotalAmountLabel.text = "$ \(ERTotalAmounts)"
        
        
        
    }
    
    override func handleNotification(notification: NSNotification) {
        
        switch notification.name {
        case Notification.Name(rawValue: "updateMyExpenseListData"):
            
            let ExpensesRealms = Storage.shareStorage.queryAllExpenseModels()
            var ExpenseTotalAmount:Float = 0.0
            for expense in ExpensesRealms {
                let amonut = (expense.jsonString.getDictionaryFromString()["nativeAmount"] as! NSString).substring(from: 4)
                ExpenseTotalAmount += Float(amonut)!
                
            }
            expensesTotalAmountLabel.text = "$ \(ExpenseTotalAmount)"
            
//        case Notification.Name(rawValue: "updateExpenseReportData"):
//          let ExpenseReportRealms = Storage.shareStorage.queryAllExpenseReports()
//            var ERTotalAmounts:Float = 0.0
//            for ER in ExpenseReportRealms {
//                let expensesRealms = Storage.shareStorage.queryExpensesModelBySuperClientId(superEKey: ER.eKey)
//                for expense in expensesRealms {
//                    let amonut = (expense.jsonString.getDictionaryFromString()["nativeAmount"] as! NSString).substring(from: 4)
//                    ERTotalAmounts += Float(amonut)!
//
//                }
//            }
//            reportsTotalAmountLabel.text = "$ \(ERTotalAmounts)"
        case Notification.Name(rawValue: "expenseRealmItemsFromNetworkNoti"):
           
            let ExpensesRealms = Storage.shareStorage.queryAllExpenseModels()
            var ExpenseTotalAmount:Float = 0.0
            for expense in ExpensesRealms {
                let amonut = (expense.jsonString.getDictionaryFromString()["nativeAmount"] as! NSString).substring(from: 4)
                ExpenseTotalAmount += Float(amonut)!
                
            }
            expensesTotalAmountLabel.text = "$ \(ExpenseTotalAmount)"
            
              print("===")
        default:
            print("==")
        }
    }

    deinit {
        
        removeNotificationObserver()
    
    }
    
    func tapClick1() {
        
       firstButtontView.backgroundColor = UIColor.lightGray
        secondButtonView.backgroundColor = UIColor.clear
        refineLabel.isHidden = false
        expenseAllButtonV.isHidden = false
        self.height = 300
        delegate?.MyExpenseReportHeaderViewWithJudge!(isExpense: true)

    }
    
    func tapClick2() {
        
        firstButtontView.backgroundColor = UIColor.clear
         secondButtonView.backgroundColor = UIColor.lightGray
        refineLabel.isHidden = true
        expenseAllButtonV.isHidden = true
        self.height = 180
        
        delegate?.MyExpenseReportHeaderViewWithJudge!(isExpense: false)
    }

}
