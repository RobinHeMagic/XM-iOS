//
//  SelectCollectionViewCell.swift
//  XM_Infor
//
//  Created by Robin He on 07/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class SelectCollectionViewCell: UICollectionViewCell {
    
    var selectImageV:UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectImageV = UIImageView()
//        selectImageV?.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 400)
        
        contentView.addSubview(selectImageV!)
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
