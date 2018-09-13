//
//  ExpenseMsgTVCell.swift
//  XM_Infor
//
//  Created by Robin He on 04/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ExpenseMsgTVCell: UITableViewCell {

    @IBOutlet weak var ExpenseAmountLabel: UILabel!
   
    @IBOutlet weak var AmountTextfield: UITextField!
    
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var DateButton: UIButton!
    @IBOutlet weak var CurrencyLabel: UILabel!
    @IBOutlet weak var CurrencyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DateButton.setTitle(nowDateString(), for: [])
        
        AmountTextfield.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        NotificationCenter.default.addObserver(self, selector: #selector(textBeginEdit(textBeginEditNotification:)),
                                               name: .UITextFieldTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textEndEdit(textEndEditNotification:)),
                                               name: .UITextFieldTextDidEndEditing, object: nil)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        AmountTextfield.resignFirstResponder()
   
    }
    
    deinit {
          NotificationCenter.default.removeObserver(self)
    }

}

extension ExpenseMsgTVCell {

    func textBeginEdit(textBeginEditNotification: Notification) {
        DateButton.isEnabled = false
        CurrencyButton.isEnabled = false
        
    }
    
    func textEndEdit(textEndEditNotification: Notification) {
        DateButton.isEnabled = true
        CurrencyButton.isEnabled = true
        
    }
}
