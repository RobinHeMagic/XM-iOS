//
//  CorpDataTimeoutModel.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 13/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift

class CorpDataTimeoutModel: Object {
    dynamic var corpDataTypeName = ""
    dynamic var date: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "corpDataTypeName"
    }
}
