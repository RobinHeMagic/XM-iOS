//
//  BusinessRuleWarningCell.swift
//  XM_Infor
//
//  Created by Robin He on 24/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class BusinessRuleWarningCell: UITableViewCell {

    @IBOutlet weak var ConfirmButton: UIButton!
    @IBOutlet weak var Messagelabel: UILabel!
    @IBOutlet weak var PolicyLabel: UILabel!

    @IBAction func ConfirmClick(_ sender: UIButton) {
        
        
        sender.isSelected = !sender.isSelected
    }
    
    var BRVModel:BusinessRuleViolationModel?{
    
        didSet{
           Messagelabel.text = BRVModel?.businessRuleInteractMesg
           ConfirmButton.isSelected = BRVModel?.userAccept == 1
           PolicyLabel.text = BRVModel?.businessRulePolicy
            
        }
    
    
    }
    
    override func awakeFromNib() {
      
        super.awakeFromNib()
       
        
        
    
    }
}
