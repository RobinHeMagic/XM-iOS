//
//  DetailMsgTVCell.swift
//  XM_Infor
//
//  Created by Robin He on 04/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class DetailMsgTVCell: UITableViewCell {

    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var contentfield: UITextField!
    @IBOutlet weak var MsgName: UILabel!
    @IBOutlet weak var checkImageV: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    var isClick = false
    var expenseFieldM:ExpenseFieldItem?{
        didSet{
            guard let expenseFieldM = expenseFieldM else {
                return
            }
            MsgName.text = expenseFieldM.label
            if  expenseFieldM.type == "string" || expenseFieldM.type == "decimal" || expenseFieldM.type == "int"{
                contentfield.isHidden = false
                contentLabel.isHidden = true
                arrowImageView.isHidden = true
                checkImageV.isHidden = true
                if expenseFieldM.type == "decimal" || expenseFieldM.type == "int" {
                    contentfield.keyboardType = UIKeyboardType.decimalPad
                }
            } else if expenseFieldM.type == "boolean"{
                contentfield.isHidden = true
                contentLabel.isHidden = true
                arrowImageView.isHidden = true
                checkImageV.isHidden = false
            } else if expenseFieldM.type == "time"{
                contentfield.isHidden = true
                contentLabel.isHidden = false
                contentLabel.text = "Please select time ..."
                contentLabel.textColor = UIColor.gray
                arrowImageView.isHidden = true
                checkImageV.isHidden = true
            } else{
                contentfield.isHidden = true
                contentLabel.isHidden = false
                arrowImageView.isHidden = false
                checkImageV.isHidden = true
                contentfield.keyboardType = UIKeyboardType.default
            }
            if expenseFieldM.required == 1{
                markLabel.isHidden = false
            }else{
                markLabel.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
  
        super.awakeFromNib()
        selectionStyle = .none
        contentfield.isHidden = true
        contentfield.addTarget(self, action: #selector(textFieldDidChanged(textField:)), for: .editingChanged)
    }

    func textFieldDidChanged(textField: UITextField) {
        NotificationCenter.default.post(name: NSNotification.Name (rawValue: "postTextOftextFieldDidChanged"), object: self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
