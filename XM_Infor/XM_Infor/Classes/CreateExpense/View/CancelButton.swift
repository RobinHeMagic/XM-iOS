//
//  CancelButton.swift
//  XM_Infor
//
//  Created by Robin He on 31/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class CancelButton: UIButton {

    
    class func XMCancelButton() -> CancelButton {
        
        let nib = UINib(nibName:"CancelButton",bundle:nil)
        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! CancelButton
    
        return btn
        
    }


}
