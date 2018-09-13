//
//  ExpenseReportFormModel.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 19/10/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift

class ExpenseReportTempModel: Object {
    dynamic var purposeId = 0
    dynamic var jsonString = ""
    
    override static func primaryKey() -> String {
        return "purposeId"
    }
}
