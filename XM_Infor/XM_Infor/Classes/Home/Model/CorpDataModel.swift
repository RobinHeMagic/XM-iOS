//
//  CorpDataModel.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 11/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift

class CorpDataModel: Object {
    dynamic var displayName = ""
    dynamic var uid = 0
    dynamic var typeName = ""
    dynamic var jsonString = ""
    
    override static func primaryKey() -> String? {
        return "uid"
    }

   class func model2NSDictionaryWith(_ alloCostCenters:[CorpDataModel]) -> [[String:Any]] {
        
        var alloCSDics = [[String:Any]]()
        
        for alloCS in alloCostCenters {
            var alloCSDic = [String:Any]()
            guard  let displayName = alloCS.value(forKey: "displayName"),
                   let uid = alloCS.value(forKey: "uid"),
                   let typeName = alloCS.value(forKey: "typeName"),
                   let jsonString = alloCS.value(forKey: "jsonString")
                else {
                    return alloCSDics
            }
            alloCSDic.updateValue(displayName, forKey: "displayName")
            alloCSDic.updateValue(uid, forKey: "uid")
            alloCSDic.updateValue(typeName, forKey: "typeName")
            alloCSDic.updateValue(jsonString, forKey: "jsonString")
            alloCSDics.append(alloCSDic)
            
        }
        
        return alloCSDics

    }
}
