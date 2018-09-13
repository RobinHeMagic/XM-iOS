//
//  CurrencyTypeItem.swift
//  XM_Infor
//
//  Created by Robin He on 12/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class CurrencyTypeItem: NSObject {
    
    var symbol: String?
    var id: Int?
    var isoCode: String?
    var displayName: String?
    init(dict: [String: AnyObject]) {
        super.init()
        symbol = dict["symbol"] as? String
        id = dict["id"] as? Int
        isoCode = dict["isoCode"] as? String
        displayName = dict["displayName"] as? String
    }

    
    
}
