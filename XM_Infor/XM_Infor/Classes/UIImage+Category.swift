//
//  UIImage+Category.swift
//  XM_Infor
//
//  Created by Robin He on 16/10/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     *  重设图片大小
     */
    func reSizeImage(reSize:CGSize)->UIImage {
        UIGraphicsBeginImageContext(reSize)
//        UIGraphicsBeginImageContextWithOptions(reSize,false,1.0)
         self.draw(in: CGRect(x:0,y:0,width:reSize.width,height:reSize.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize:CGFloat)->UIImage {
       let reSi = CGSize(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize:reSi)
    }
}
