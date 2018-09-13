//
//  expenseTypeTabCell1.swift
//  XM_Infor
//
//  Created by Robin He on 31/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class expenseTypeTabCell: UITableViewCell {

    @IBOutlet weak var expenseTypeNameLabel: UILabel!
    @IBOutlet weak var expenseTypeImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.colorWithRGB(245, g: 246, b: 248)
        bgView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
