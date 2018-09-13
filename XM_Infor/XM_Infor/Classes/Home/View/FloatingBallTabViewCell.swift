//
//  FloatingBallTabViewCell.swift
//  XM_Infor
//
//  Created by Robin He on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

@objc
protocol FloatingBallTabViewCellDelegate:NSObjectProtocol {
    
    @objc optional func FloatingBallTabViewCellRightButtonClicked(isUp:Bool)
    
}
class FloatingBallTabViewCell: UITableViewCell {

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    var isUp = false
    weak var delegate:FloatingBallTabViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.width = getLength(leng: 150)
    
    
    }

    @IBAction func rightButtonClick(_ sender: UIButton) {
        
        isUp = !isUp
        
        sender.setImage(UIImage(named: isUp ? "up" : "down"), for: [])
        
        delegate?.FloatingBallTabViewCellRightButtonClicked!(isUp: isUp)
    }
    
}
