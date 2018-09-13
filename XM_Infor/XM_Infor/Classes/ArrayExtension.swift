//
//  ArrayExtension.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 15/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

extension Array {
    
    //Array -> JSON
    func getJSONStringFromArray() -> String {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("Can not change to JSONString")
            return""
        }
        let data: Data! = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) as Data!
        let jsonString = String(data: data as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return jsonString!
    }
    
}
