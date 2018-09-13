//
//  CreatExpenseButton.swift
//  XM_Infor
//
//  Created by Robin He on 06/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class CreatExpenseButton: UIView {

   class  func LoadXibBtn() -> CreatExpenseButton{
        
        return Bundle.main.loadNibNamed("CreatExpenseButton", owner: nil, options: nil)?.first as! CreatExpenseButton
    }
    
}
