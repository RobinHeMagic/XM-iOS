//
//  BusinessRuleViolationModel.swift
//  XM_Infor
//
//  Created by Robin He on 24/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift
class BusinessRuleViolationModel: NSObject {
    
//     var message:String?
     var clientId:String?
     var uid :Int64?
//     var level:Int?
     var ruleId:Int64?
     var userAccept:Int?
     var businessRulePolicy:String?
     var explanation:String?
    var businessRuleSeverity:Int?
    var businessRuleInteractMesg:String?
    
    init(dict: [String:Any]) {
        
        super.init()
        businessRuleInteractMesg = dict["businessRuleInteractMesg"] as? String
//        clientId = dict["eKey"] as? String
        clientId = dict["eKey"] as? String

        uid = dict["uid"] as? Int64
//        level = dict["level"] as? Int
        ruleId = dict["ruleId"] as? Int64
        userAccept = dict["userAccept"] as? Int
        businessRulePolicy = dict["businessRulePolicy"] as? String
        explanation = dict["explanation"] as? String
        businessRuleSeverity = dict["businessRuleSeverity"] as? Int
    }


}
