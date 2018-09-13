//
//  XIBExtension.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

extension UILabel{
    @IBInspectable var textHexColor: NSString {
        get {
            return "0xffffff";
        }
        set {
            let scanner = Scanner(string: newValue as String)
            var hexNum = 0 as UInt32
            
            if (scanner.scanHexInt32(&hexNum)){
                let r = (hexNum >> 16) & 0xFF
                let g = (hexNum >> 8) & 0xFF
                let b = (hexNum) & 0xFF
                
                self.textColor = UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
            }
        }
    }
}

extension UIView{
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            //            return UIColor(CGColor: layer.borderColor!)!
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var hexRgbColor: NSString {
        get {
            return "0xffffff";
        }
        set {
            
            let scanner = Scanner(string: newValue as String)
            var hexNum = 0 as UInt32
            
            if (scanner.scanHexInt32(&hexNum)){
                let r = (hexNum >> 16) & 0xFF
                let g = (hexNum >> 8) & 0xFF
                let b = (hexNum) & 0xFF
                
                self.backgroundColor = UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
            }
            
        }
    }
    
    //    @IBInspectable var onePx: Bool {
    //        get {
    //            return self.onePx
    ////            return true
    //        }
    //        set {
    //            if (onePx == true){
    ////                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1 / UIScreen.main.scale)
    //                self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: 1 / UIScreen.main.scale)
    //            }
    //        }
    //    }
}
