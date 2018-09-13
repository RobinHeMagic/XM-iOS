//
//  XMSize.swift
//  XM_Infor
//
//  Created by Robin He on 14/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

enum XMSizeType {
    case SizeTypeNone
    case SizeType3_5
    case SizeType4_0
    case SizeType4_7
    case SizeType5_5
    case SizeType5_8
}
class XMSize: NSObject {

    let dict:[Int:CGFloat] = [0:0,
                1:320,
                2:320,
                3:375,
                4:414,
                5:375]
    
   class func getCurrentRatioSizeType() -> Int{
    
    var value:Int = 0

    if XMSize.CGSizeEqualToDeviceSize(width: 320.0,height: 480.0,andScreenWidth: SCREEN_SIZE) {
        
        value = 1
    } else if XMSize.CGSizeEqualToDeviceSize(width: 320.0,height: 568.0,andScreenWidth: SCREEN_SIZE){
    
        value = 2
    } else if XMSize.CGSizeEqualToDeviceSize(width: 375.0,height: 667.0,andScreenWidth: SCREEN_SIZE){
        
        value = 3
    } else if XMSize.CGSizeEqualToDeviceSize(width: 414.0,height: 736.0,andScreenWidth: SCREEN_SIZE){
    
        value = 4
        
    } else if XMSize.CGSizeEqualToDeviceSize(width: 375.0,height: 812.0,andScreenWidth: SCREEN_SIZE){
        
        value = 5
        
    }
    
    return value

   }
    
    func getLengthWithSizeType(sizeType:XMSizeType, andLength length:CGFloat) -> CGFloat {
        
        switch sizeType {
       
        case XMSizeType.SizeType3_5:
            return length * dict[XMSize.getCurrentRatioSizeType()]!/dict[1]!
        case XMSizeType.SizeType4_0:
            return length * dict[XMSize.getCurrentRatioSizeType()]!/dict[2]!
        case XMSizeType.SizeType4_7:
            return length * dict[XMSize.getCurrentRatioSizeType()]!/dict[3]!
        case XMSizeType.SizeType5_5:
            return length * dict[XMSize.getCurrentRatioSizeType()]!/dict[4]!
        case XMSizeType.SizeType5_8:
            return length * dict[XMSize.getCurrentRatioSizeType()]!/dict[5]!
        default:
            print("")
        }
        
        return 0.0
    }
   class func CGSizeEqualToDeviceSize(width:CGFloat,height:CGFloat, andScreenWidth ScreenWidth:CGSize) -> Bool {
    
        return CGSize(width: width, height: height) == ScreenWidth
    }
}
