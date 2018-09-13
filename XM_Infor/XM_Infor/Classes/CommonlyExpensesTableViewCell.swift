//
//  CommonlyExpensesTableViewCell.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 01/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class CommonlyExpensesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var expenseTypeLabel: UILabel!

    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var grayLabel1: UILabel!
    
    @IBOutlet weak var grayLabel2: UILabel!
    
    @IBOutlet weak var checkBox: UIImageView!
    
    @IBOutlet weak var colorBar: UIView!
    
    @IBOutlet weak var internalView: UIView!
    
    @IBOutlet weak var stateTitleLabel: UILabel!
    
    @IBOutlet weak var stateContentLabel: UILabel!
    
    var expenseModel:ExpensesModel?{
        didSet{
            guard let expenModel = expenseModel
                else {
                return
            }
            let exReportModel = Storage.shareStorage.queryAllExpenseReports().filter("eKey = %@",expenModel.superEKey).first
            
            let jsonStr = expenModel.jsonString.getDictionaryFromString()
//            let amount = jsonStr["nativeAmount"]
            let status = expenModel.status
           
            expenseTypeLabel.text = jsonStr["expenseName"] as?String
            
//            amountLabel.text = jsonStr["nativeAmount"] as?String
            amountLabel.text = (jsonStr["nativeAmount"] as! NSString).substring(from: 4)

            stateTitleLabel.text = status
            switch status {
            case "draft":
                stateContentLabel.text = "draft"
                stateContentLabel.textColor = UIColor.gray
            case "valid":
                stateContentLabel.text = "Validated"
                stateContentLabel.textColor = UIColor.green
                
            case "invalid":
                stateContentLabel.text = "Has issue"
                stateContentLabel.textColor = UIColor.red
            case "valid_BRV":
                
                stateContentLabel.text = "Pending confirmation"
                stateContentLabel.textColor = UIColor.orange
            case "done":
              
                stateContentLabel.text = exReportModel?.trackingNumber
                stateContentLabel.textColor = UIColor.darkGray
                print("")
            default:
                print("===")
            }

        }
        
    }

    
    var cellType = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.backgroundColor = UIColor.colorWithRGB(245, g: 246, b: 248)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
