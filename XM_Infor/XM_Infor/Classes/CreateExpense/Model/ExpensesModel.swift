//
//  ExpensesModel.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 31/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift

class ExpensesModel: Object {
    
    //********************STATUS EXPLANATION******************
    // draft        * - Expense has just been created and hasn't been send to rhe server.
    // done         * - The expense has been successfully submitted.
    // invalid      * - Return JSON has error or one or more invalid-severity BRVs.
    // valid_BRV    * - Return JSON has no error and all BRVs are not invalid-severity BRVs.
    // valid        * - Return JSON has neither error or BRV.
    
    dynamic var superEKey:String = ""
    dynamic var eKey:String = ""
    dynamic var date:String = ""
    dynamic var status: String = "draft"
    dynamic var lock = false
    dynamic var jsonString:String = ""
    dynamic var displayUI = ""
    
    override static func primaryKey() -> String {
        return "eKey"
    }
    
    func dictionaryWith(expense:[String:Any]) {
        
        if expense["superEKey"] != nil {
            superEKey = expense["superEKey"] as! String
        }
        
        eKey = expense["eKey"] as! String
        
        date = expense["date"] as! String

        if expense["status"] != nil {
            status = expense["status"] as! String
        }
        
        if expense["lock"] != nil {
            lock = expense["lock"] as! Bool
        }
        
        if expense["displayUI"] != nil {
            displayUI = expense["displayUI"] as! String
        }
        
        if expense["jsonString"] != nil {
            jsonString = expense["jsonString"] as! String
        }
//        jsonString = expense.getJSONStringFromDictionary()
    }

}
