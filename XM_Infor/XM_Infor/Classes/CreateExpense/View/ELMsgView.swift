//
//  ELMsgView.swift
//  XM_Infor
//
//  Created by Robin He on 05/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ELMsgView: UIView {

    @IBOutlet weak var totalAmountLabel: UILabel!
   
  class func elmsgView() -> ELMsgView {
    
    return Bundle.main.loadNibNamed("ELMsgView", owner: self, options: nil)?.last as! ELMsgView
    
    }

    


}
