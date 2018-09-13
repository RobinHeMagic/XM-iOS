//
//  StringExtension.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 12/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

extension String {
    
    // String -> Dictionary
    func getDictionaryFromString() ->NSDictionary{
        
        let jsonData:Data = self.data(using: .utf8)!
        
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    
    func dateChange(dformatter:DateFormatter,nowDate:Date) -> String {
        
        let  dateStr  = (dformatter.string(from: nowDate) as NSString).substring(with: NSMakeRange(3, 2))
        switch dateStr {
        case "01":
            return (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "January")
        case "02":
            return (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "February")
        case "03":
            return (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "March")
        case "04":
            return  (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "April")
        case "05":
            return (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "May")
        case "06":
            return (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "June")
        case "07":
            return  (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "July")
        case "08":
            return  (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "August")
        case "09":
            return  (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "September")
        case "10":
            return  (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "October")
        case "11":
            return  (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "November")
        case "12":
            return  (dformatter.string(from: nowDate) as NSString).replacingCharacters(in: NSMakeRange(3, 2), with: "December")
        default:
            print("")
        }
        return ""
    }
   
}
