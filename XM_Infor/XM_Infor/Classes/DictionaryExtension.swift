//
//  DictionaryExtension.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 12/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

extension Dictionary {
    
    
    //Dictionary -> JSON
    func getJSONStringFromDictionary() -> String {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("Can not change to JSONString")
            return ""
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: self, options: []) as NSData!
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
        
    }
    //add a dictionary into another
    mutating func merge(dict:Dictionary) {
        for (k,v) in dict {
            updateValue(v, forKey: k)
        }
    }

    //Dictionary -> JSON
    func toJSONString()->String{
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let strJson = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return strJson! as String
    }
}
