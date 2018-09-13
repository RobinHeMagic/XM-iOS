//
//  ExpenseFieldItem.swift
//  XM_Infor
//
//  Created by Robin He on 11/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ExpenseFieldItem: NSObject {

    var name: String?
    var label: String?
    var type: String?
    var required: Int?
    var bySearch:Int?
    var option:Int?
    init(dict: [String: Any]) {
        super.init()
        name = dict["name"] as? String
        label = dict["label"] as? String
        type = dict["type"] as? String
        required = dict["required"] as? Int
        bySearch = dict["bySearch"] as? Int
        option = dict["option"] as?Int
    }

}
