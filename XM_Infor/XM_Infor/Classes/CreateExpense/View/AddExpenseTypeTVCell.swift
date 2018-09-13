//
//  AddExpenseTypeTVCell.swift
//  XM_Infor
//
//  Created by 何兵兵 on 2017/7/8.
//  Copyright © 2017年 Robin He. All rights reserved.
//

import UIKit

class AddExpenseTypeTVCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var allocationTypeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        allocationTypeLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
