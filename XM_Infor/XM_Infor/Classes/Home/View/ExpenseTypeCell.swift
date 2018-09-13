//
//  ExpenseTypeCell.swift
//  XM_Infor
//
//  Created by Robin He on 06/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ExpenseTypeCell: UICollectionViewCell {

    @IBOutlet weak var ExpenseTypeTitle: UILabel!
    @IBOutlet weak var ExpenseTypeImageV: UIImageView!
    override func awakeFromNib() {
        
        super.awakeFromNib()
//        backgroundColor = UIColor.colorWithRGB(22, g: 78, b: 112)
        ExpenseTypeImageV.layer.borderWidth = 0.5
        ExpenseTypeImageV.layer.borderColor = UIColor.gray.cgColor
        ExpenseTypeImageV.layer.cornerRadius = 30
        ExpenseTypeImageV.layer.masksToBounds = true
        
   
    }

}
