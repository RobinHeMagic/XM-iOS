//
//  BusinessRuleExplenlationCell.swift
//  XM_Infor
//
//  Created by Robin He on 24/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class BusinessRuleExplenlationCell: UITableViewCell {

    @IBOutlet weak var explanationTextView: UITextView!
    @IBOutlet weak var PolicyLabel: UILabel!
    @IBOutlet weak var MessageLabel: UILabel!
    
    
    var expBRVModel:BusinessRuleViolationModel?{
        
        didSet{
            PolicyLabel.text = expBRVModel?.businessRulePolicy
            MessageLabel.text = expBRVModel?.businessRulePolicy
            
            if expBRVModel?.explanation != nil {
                 explanationTextView.text = "Explanations has been finished editing"
                explanationTextView.textColor = UIColor.green
            }
           explanationTextView.isEditable = (expBRVModel?.explanation == nil)
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }

}
