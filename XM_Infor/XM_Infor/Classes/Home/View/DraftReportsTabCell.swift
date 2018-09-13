//
//  DraftReportsTabCell.swift
//  XM_Infor
//
//  Created by Robin He on 31/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift
class DraftReportsTabCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var errorInfoLabel: UILabel!
    
    @IBOutlet weak var reportTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalAmountabel: UILabel!
    
    
//    var superClientId = 0
    
    var expenseReportItem:ExpenseReportModel?{
        didSet{
            var totalAmount:Float = 0.0
            let superEKey = expenseReportItem?.jsonString.getDictionaryFromString()["eKey"] as! String
            let ExpenseModels = Storage.shareStorage.queryExpensesModelBySuperEKey(superEKey: superEKey)
            
            for expense in ExpenseModels {
              totalAmount += (expense.jsonString.getDictionaryFromString()["nativeAmount"] as![String:Any])["amount"] as! Float
            }
            totalAmountabel.text = "$\(totalAmount)"
            dateLabel.text = expenseReportItem?.createDate
            reportTitleLabel.text = expenseReportItem?.jsonString.getDictionaryFromString()["title"] as? String
        }
    
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.colorWithRGB(245, g: 246, b: 248)
        bgView.layer.cornerRadius = 10
    }
    
}
