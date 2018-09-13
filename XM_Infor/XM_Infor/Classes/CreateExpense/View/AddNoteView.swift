//
//  AddNoteView.swift
//  XM_Infor
//
//  Created by Robin He on 05/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class AddNoteView: UIView {

    var label = UILabel(frame:CGRect(x:60,y:10,width:150,height:45))
    
    var btn = UIButton(frame:CGRect(x:20,y:15,width:30,height:30))
    
    var  imageV = UIImageView(frame:CGRect(x: 300,y:25,width:10,height:10))
    
     init(frame: CGRect,str:String) {
        super.init(frame: frame)
        label.text = str
        label.textColor = UIColor.colorWithRGB(22, g: 78, b: 112)
        backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        btn.setImage(UIImage(named:"plus74"), for:.normal)
        imageV.image = UIImage(named:"arrow-right")
        addSubview(btn)
        addSubview(label)
        addSubview(imageV)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
