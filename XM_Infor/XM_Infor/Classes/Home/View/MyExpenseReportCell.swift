//
//  MyExpenseReportCell.swift
//  XM_Infor
//
//  Created by Robin He on 25/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class MyExpenseReportCell: UITableViewCell {

    @IBOutlet weak var trackingNumberLabel: UILabel!
    @IBOutlet weak var ExportTotalAmount: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var totalAmount:Float = 0.0
    var superEKey = ""
    var ExpenseReport:ExpenseReportModel?{
        didSet {
            
           superEKey = (ExpenseReport?.eKey)!
            if ExpenseReport!.jsonString.getDictionaryFromString()["status"] is String? {
                statusLabel.text = ExpenseReport!.jsonString.getDictionaryFromString()["status"] as? String ?? ""
            } else {
                let corpDataTOMList = Storage.shareStorage.queryExpensesModelBySuperEKey(superEKey: superEKey)
                
                var totalMoney:Float = 0.0
                for i in 0..<corpDataTOMList.count {
                    totalMoney += corpDataTOMList[i].jsonString.getDictionaryFromString()["amount"]! as! Float
                }
                
                if "$ \(totalMoney)" == "$ 0.0"{
                    var dict = [String:Any]()
                    dict.updateValue("draft", forKey: "status")
                    dict.updateValue("ER example", forKey: "title")
                    dict.updateValue(3083580, forKey: "purpose")
                    dict.updateValue((ExpenseReport?.eKey)!, forKey: "eKey")

                    let ERDict = ["jsonString":dict.getJSONStringFromDictionary()]
                    Storage.shareStorage.updateExpensesReportWithEKey(eKey: superEKey, andExpenseReportDict: ERDict)
                    
                    statusLabel.text = ExpenseReport!.jsonString.getDictionaryFromString()["status"] as? String ?? ""
                    
                } else {
                    statusLabel.text = (ExpenseReport!.jsonString.getDictionaryFromString()["status"]! as! NSDictionary)["activityName"] as? String ?? ""
                    
            
                }
            }
           
            trackingNumberLabel.text =  Storage.shareStorage.queryExpenseReportModel(eKey: superEKey).trackingNumber

             updateMyTotalNoti()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
//      updateMyTotalNoti()
        let corpDataTOMList = Storage.shareStorage.queryExpensesModelBySuperEKey(superEKey: superEKey)
        
        for i in 0..<corpDataTOMList.count {
            totalAmount += corpDataTOMList[i].jsonString.getDictionaryFromString()["amount"]! as! Float
        }
        ExportTotalAmount.text = "$ \(totalAmount)"
      trackingNumberLabel.text =  Storage.shareStorage.queryExpenseReportModel(eKey: superEKey).trackingNumber
    }
    
    
    func updateMyTotalNoti() {
        
        let corpDataTOMList = Storage.shareStorage.queryExpensesModelBySuperEKey(superEKey: superEKey)
        var totalMoney:Float = 0.0
        for i in 0..<corpDataTOMList.count {
            totalMoney += corpDataTOMList[i].jsonString.getDictionaryFromString()["amount"]! as! Float
        }
        ExportTotalAmount.text = "$ \(totalMoney)"
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
}
