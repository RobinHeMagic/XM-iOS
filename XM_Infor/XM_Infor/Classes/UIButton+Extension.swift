//
//  UIButton+Extension.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 04/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

enum ButtonImagePosition : Int{
    
    case PositionTop = 0
    case Positionleft
    case PositionBottom
    case PositionRight
}

extension UIButton {
    
    /// Set image and title for button.
    ///
    /// - Parameters:
    ///   - imageName: imageName
    ///   - title: button title
    ///   - type: button image position
    ///   - space: space between image and title
    func setImageAndTitle(imageName_normal: String, imageName_selected: String, title: String, type: ButtonImagePosition, Space space: CGFloat)  {
        
        self.setTitle(title, for: .normal)
        self.setImage(UIImage(named:imageName_normal), for: .normal)
        self.setTitle(title, for: .selected)
        self.setImage(UIImage (named: imageName_selected), for: .selected)
        
        let imageWidth :CGFloat = (self.imageView?.frame.size.width)!;
        let imageHeight :CGFloat = (self.imageView?.frame.size.height)!;
        
        var labelWidth :CGFloat = 0.0;
        var labelHeight :CGFloat = 0.0;
        
        labelWidth = CGFloat(self.titleLabel!.intrinsicContentSize.width);
        labelHeight = CGFloat(self.titleLabel!.intrinsicContentSize.height);
        
        var  imageEdgeInsets :UIEdgeInsets = UIEdgeInsets();
        var  labelEdgeInsets :UIEdgeInsets = UIEdgeInsets();
        
        switch type {
        case .PositionTop:
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - space/2.0, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, -imageHeight-space/2.0, 0);
            break;
        case .Positionleft:
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
            break;
        case .PositionBottom:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWidth, 0, 0);
            break;
        case .PositionRight:
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWidth-space/2.0, 0, imageWidth+space/2.0);
            break;
        }
        

        self.titleEdgeInsets = labelEdgeInsets;
        self.imageEdgeInsets = imageEdgeInsets;
    }
}
