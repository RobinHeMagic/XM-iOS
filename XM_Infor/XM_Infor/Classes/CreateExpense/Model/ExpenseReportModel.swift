//
//  ExpenseReportModel.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 19/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift


class ExpenseReportModel: Object {
//    dynamic var uid = 0
    dynamic var eKey = ""
    dynamic var trackingNumber = ""
    dynamic var createDate = ""
    dynamic var status = ""
    dynamic var jsonString = ""
    
    override static func primaryKey() -> String {
        return "eKey"
    }
    
    func write(er: [String: Any]) {
        
        eKey = er["eKey"] as! String
        status = er["status"] as! String
        createDate = er["createDate"] as? String ?? ""
        jsonString = er.getJSONStringFromDictionary()
        
    }
    
    func update(er: [String: Any]) {
        
        status = er["status"] as! String
        createDate = er["createDate"] as? String ?? ""
        jsonString = er.getJSONStringFromDictionary()
        
    }
    
    func read() -> [String: Any] {
        var er: [String: Any] = jsonString.getDictionaryFromString() as! [String: Any]
//        er.removeValue(forKey: "uid")
        er.removeValue(forKey: "trackingNumber")
        er.removeValue(forKey: "status")
        return er
    }
}
