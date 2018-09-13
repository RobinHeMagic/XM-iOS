//
//  ExpenseLineItemTempModel.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 26/10/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift

class ExpenseLineItemTempModel: Object {
    
    dynamic var expenseTypeId = 0
    dynamic var jsonString = ""
    
    override static func primaryKey() -> String {
        return "expenseTypeId"
    }
    
}
