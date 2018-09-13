//
//  ExpenseType.swift
//  XM_Infor
//
//  Created by Robin He on 07/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ExpenseTypeItem: NSObject {

    var displayName: String?
    var id: Int?
    var imageName: String?
    
    init(dict: [String: AnyObject]) {
        super.init()
        displayName = dict["displayName"] as? String
        id = dict["id"] as? Int
        imageName = dict["imageName"] as? String
    }
}
