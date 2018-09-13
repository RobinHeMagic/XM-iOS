//
//  BObIDModel.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 25/10/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift

class BObIDModel: Object {

    dynamic var uid = 0
    
    override static func primaryKey() -> String {
        return "uid"
    }
    
}
