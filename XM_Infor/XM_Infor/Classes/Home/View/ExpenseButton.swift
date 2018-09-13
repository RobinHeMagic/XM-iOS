//
//  ExpenseButton.swift
//  XM_Infor
//
//  Created by Robin He on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ExpenseButton: UIControl {

    @IBOutlet weak var BGimageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    class func XMExpenseButton(imageName:String,title:String) -> ExpenseButton {
        
        let nib = UINib(nibName:"ExpenseButton",bundle:nil)
        

        let btn = nib.instantiate(withOwner: nil, options: nil)[0] as! ExpenseButton
        
        btn.imageView.image = UIImage(named: imageName)
        btn.titleLabel.text = title
        btn.BGimageView.isHidden = true
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        return btn

    }
    
}
