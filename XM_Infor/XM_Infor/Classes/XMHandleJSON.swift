//
//  XMHandleJSON.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 03/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import RealmSwift

class XMHandleJSON: NSObject {
    
    func handleToken(value: Any, finished:@escaping (_ isSuccess: Bool) -> ()) {
        let json = JSON(value)
        
        if json.dictionaryObject?["token"] != nil {
            
           token = json["token"].stringValue
            
            UserDefaults.Token.set(value: token, forKey: .token)
            finished(true)
            print("userToken = ", UserDefaults.Token.string(forKey: .token) as Any)
            
        }else{
            
            finished(false)
            
        }
    }

    func handleCorpData(value: Any, type: String, finished: @escaping (_ corpDataItems: [CorpDataModel]) -> ()) {
        let json = JSON(value)
        if let items = json.arrayObject {
            var homeItems = [CorpDataModel]()
            for item in items {
                let dict: [String: Any] = self.changeOtherParamToJsonString(item: item, requiredParam: "uid")
                let homeItem = CorpDataModel(value: dict)
                
                homeItem.displayName = (item as! [String: Any])["-displayName"] as! String
                homeItem.typeName = type
                homeItems.append(homeItem)
                Storage.shareStorage.saveOrUpdateData(model: homeItem)
            }
            //            let corpDataTOM = CorpDataTimeoutModel(value: ["corpDataTypeId": corpDataTypeId, "date": NSDate().timeIntervalSince1970])
            //            Storage.shareStorage.saveOrUpdateData(model: corpDataTOM)
            finished(homeItems)
        }
    }
    
    func handleCorporateDataBySearch(value: Any, keyWord: String, type: String, finished: @escaping (_ corpDataItems: [CorpDataModel]) -> ()) {
        let json = JSON(value)
        
        if let items = json.arrayObject {
            var homeItems = [CorpDataModel]()
            for item in items {
                let dict: [String: Any] = self.changeOtherParamToJsonString(item: item, requiredParam: "uid")
                let homeItem = CorpDataModel(value: dict)

                homeItem.displayName = (item as! [String: Any])["-displayName"] as! String
                homeItem.typeName = type
                homeItems.append(homeItem)
                if keyWord != "" {
                }else{
                Storage.shareStorage.saveOrUpdateData(model: homeItem)
                }
            }
//            let corpDataTOM = CorpDataTimeoutModel(value: ["corpDataTypeId": corpDataTypeId, "date": NSDate().timeIntervalSince1970])
//            Storage.shareStorage.saveOrUpdateData(model: corpDataTOM)
            finished(homeItems)
        }
    }

    func handleExpenseReportForm(purposeId: Int, value: Any, finished:@escaping (_ fieldItems: [String: Any]) -> ()) {
        let json = JSON(value)
        if let item = json.dictionaryObject {
            let expenseReportForm = ExpenseReportTempModel()
            expenseReportForm.purposeId = purposeId
            expenseReportForm.jsonString = item.getJSONStringFromDictionary()
            Storage.shareStorage.saveOrUpdateData(model: expenseReportForm)
            finished(item)
        }
        ///If get the error information
//        if let messageDict = dict.dictionaryObject {
//
//            ///Failed to validate token
//            if messageDict["message"] as! String == "Failed to validate token" {
//
//                print("MESSAGE: Failed to validate token")
//
//                let queue = DispatchQueue.init(label: "getToken")
//
//                queue.sync {
//
//                    XMNetworking.shareInstance.getLoginToken(param: loginParam, serverUrl: serviceUrl) { (bo) in
////                        XMNetworking.shareInstance.getExpenseReportForm(purposeId: purposeId, finished: finished)
//
//                    }
//                }
//            }
//        }
    }
        
    func handleExpenseLineItemTemp(value: Any, expenseTypeId: Int, needReference: Bool, finished:@escaping (_ fieldItems: [[String: Any]]) -> ())  {
        let json = JSON(value)
        let expenseLineItemTemp = ExpenseLineItemTempModel()
        var fieldArr: [[String: Any]] = []
        var fieldsDesc: [[String: Any]] = []
        var result: [[String: Any]] = []
        
        if var dictionary = json.dictionaryObject {
            // Save expense line item temp
            let uidDict: [String: Any] = ["uid": dictionary["uid"] as Any]
            let dateDcit: [String: Any] = ["date": dictionary["date"] as Any]
            let uniqueInfor = [uidDict, dateDcit]
            
            dictionary.removeValue(forKey: "uid")
            dictionary.removeValue(forKey: "date")
            expenseLineItemTemp.expenseTypeId = dictionary["expenseType"] as! Int
            
            //Remove Guests
            var metadata = dictionary["-metadata"] as! [String: Any]
            metadata.removeValue(forKey: "guestName")
            dictionary.updateValue(metadata, forKey: "-metadata")
            
            expenseLineItemTemp.jsonString = dictionary.toJSONString()
            Storage.shareStorage.saveOrUpdateData(model: expenseLineItemTemp)
            
            let fields: [String: [String: Any]] = dictionary["-metadata"] as! [String: [String: Any]]
            
            for (key, value) in fields {
                if key != "date" || key != "nativeAmount" {
                    fieldArr.append(value)
                }
            }
            fieldsDesc = fieldArr.sorted(by: { (t1, t2) -> Bool in
                return (t1["order"] as! Int) < (t2["order"] as! Int) ? true:false
            })
            
            
            
            dictionary.removeValue(forKey: "-metadata")
            result = [
                ["uniqueInfor": uniqueInfor],
                ["metadata": fieldsDesc],
                ["defaultConfig": dictionary]
            ]
        }
        finished(result)
    }
    
    func handleChargeCode(value: Any, project: Bool, costCenter: Bool, finished: @escaping (_ chargeCodeItems: [CorpDataModel]) -> ()) {
        let json = JSON(value)
        var chargeCodeModels = [CorpDataModel]()
        
        if let items: Array<[String: Any]> = json.arrayObject as? Array<[String : Any]> {
            for item in items {
                let chargeCodeItem = CorpDataModel()
                chargeCodeItem.typeName = "ChargeCode"
                chargeCodeItem.displayName = item["-displayName"] as! String
                chargeCodeItem.jsonString = item.getJSONStringFromDictionary()
                chargeCodeItem.uid = item["uid"] as! Int
                chargeCodeModels.append(chargeCodeItem)
            }
         finished(chargeCodeModels)
        }
    }
    
    func handleBObID(value: Any, max: Int) {
        let json = JSON(value)
        if let items: Array<Int> = json.arrayObject as? Array<Int> {
            for item in items {
                let bobIDModel = BObIDModel()
                bobIDModel.uid = item
                Storage.shareStorage.saveOrUpdateData(model: bobIDModel)
            }
        }
    }
    
    func handleExpenseLineItem(value: Any, isCC: Bool, isReference: Bool, finished:@escaping (_ ccExpenseLineItems: [ExpensesModel]) -> ()) {
        let json = JSON(value)
        if let items = json.arrayObject {
            var lineItems = [ExpensesModel]()

            for item in items {
                let eKey = Storage.shareStorage.takeEKey()
                var itemDict = item as! [String: Any]
                itemDict.updateValue(eKey, forKey: "eKey")
                var dict: [String: Any] = ["jsonString": itemDict.getJSONStringFromDictionary()]
                
                dict.updateValue(0, forKey: "superClient")
                dict.updateValue(eKey, forKey: "eKey")
                dict.updateValue((item as! [String: Any])["date"] ?? "", forKey: "date")
                dict.updateValue(false, forKey: "lock")
                
                if Array((item as! [String: Any]).keys).contains("expenseType") {
                    dict.updateValue("draft", forKey: "status")
                }else{
                    dict.updateValue("invalid", forKey: "status")
                }
                
                let expenseItem = ExpensesModel(value: dict)
                Storage.shareStorage.saveOrUpdateData(model: expenseItem)
                lineItems.append(expenseItem)
            }
            finished(lineItems)
        }
        
        ///If get the error information
        if let messageDict = json.dictionaryObject {
            
            ///Failed to validate token
            if messageDict["message"] as! String == "Failed to validate token" {
                
                print("MESSAGE: Failed to validate token")
                
                let queue = DispatchQueue.init(label: "getToken")
                
                queue.sync {
                    
                    XMNetworking.shareInstance.getLoginToken(param: loginParam, serverUrl: serviceUrl) { (bo) in
                        XMNetworking.shareInstance.getExpenselineItem(isCC: isCC, isReference: isReference, finished: finished)
                        
                    }
                }
            }
        }
    }
        
    func handleLineItemPost(postMode: String, expense: [String: Any], value: Any, finished: @escaping (_ isSuccess: Bool) -> ()) {
        var eKey = ""
        if let ekey = expense["-key"] {
            eKey = ekey as! String
        }
        if let ekey = expense["eKey"] {
            eKey = ekey as! String
        }
        
        let expenseModel = Storage.shareStorage.queryExpensesModelByEKey(eKey: eKey , applyLock: false)!
        let lineItemModel: ExpensesModel = expenseModel
        let json = JSON(value)
        var stringDict: [String: Any] = lineItemModel.jsonString.getDictionaryFromString() as! [String: Any]
        
        if let item = json.dictionaryObject {
            // Has error
            if let error: [String: Any] = item["-error"] as? [String : Any] {
                stringDict.merge(dict: ["error": error])
                try! XMRealm.write {
                    lineItemModel.status = "invalid"
                    // Append error message.
                    lineItemModel.jsonString = stringDict.getJSONStringFromDictionary()
                }
                
            }else {
                // No error but brv
                // case1: businessRuleSeverity == 0 -> invalid
                // case2: businessRuleSeverity >0 -> valid_BRV
                
                if let brvs: Array<[String: Any]> = item["-brv"] as? Array<[String: Any]> {
                    
                    stringDict.merge(dict: ["-brv": brvs])
                    
                    try! XMRealm.write {
                        lineItemModel.jsonString = stringDict.getJSONStringFromDictionary()
                    }
                    
                    var isInvalid = false
                    
                    for brv in brvs {
                        
                        let businessRuleSeverity: Int = brv["businessRuleSeverity"] as! Int
                        if businessRuleSeverity == 0 {
                            
                            isInvalid = true
                            break
                            
                        }
                    }
                    
                    try! XMRealm.write {
                        if isInvalid {
                            lineItemModel.status = "invalid"
                        }else{
                            lineItemModel.status = "valid_BRV"
                        }
                    }
                    
                }else{
                    //No error and brv
                    try! XMRealm.write {
                        lineItemModel.status = "valid"
                    }
                }
            }
            finished(true)
        }
        
        if let messageDict = json.dictionaryObject?["message"] {
            
            ///Failed to validate token
            if messageDict as! String == "Failed to validate token" {
                
                print("MESSAGE: Failed to validate token")
                
                let queue = DispatchQueue.init(label: "getToken")
                
                queue.sync {
                    
                    XMNetworking.shareInstance.getLoginToken(param: loginParam, serverUrl: serviceUrl) { (bo) in
                        XMNetworking.shareInstance.postExpenseLineItem(postMode: postMode, expense: expense, finished: finished)
                    }
                }
            }
        }
    }
    
    func handleExpenseReport(postMode: String,lineItemEKeyArr: Array<String>, expenseReport: [String: Any], value: Any, finished: @escaping (_ isSuccess: Any) -> ()) {
        
        let json = JSON(value)
        let expenseReportModel = Storage.shareStorage.queryExpenseReportModel(eKey: expenseReport["eKey"] as! String)
        var stringDict: [String: Any] = expenseReportModel.jsonString.getDictionaryFromString() as! [String : Any]
        
        if let item = json.dictionaryObject {
            //Has error
            if let error: [String: Any] = item["error"] as? [String: Any] {
                stringDict.merge(dict: ["error": error])
                try! XMRealm.write {
                    expenseReportModel.jsonString = stringDict.getJSONStringFromDictionary()
                }
                finished(error)
            }else{//No error
                if let brvs: Array<[String: Any]> = item["-brv"] as? Array<[String: Any]> {//No error but BRV
                    stringDict.merge(dict: ["-brv": brvs])
                    try! XMRealm.write {
                        expenseReportModel.jsonString = stringDict.getJSONStringFromDictionary()
                    }
                    finished(brvs)
                }else{// No error No BRV
                    for lineItemEKey in lineItemEKeyArr {
                        let lineItemModel = Storage.shareStorage.queryExpensesModelByEKey(eKey: lineItemEKey, applyLock: false)
                        try! XMRealm.write {
                            if lineItemModel != nil {
                                lineItemModel?.status = "done"
                            }else{
                                
                            }
                        }
                    }
                    try! XMRealm.write {
                        expenseReportModel.trackingNumber = item["envelopeID"] as! String
                        expenseReportModel.status = "submited"
                    }
                    finished("success")
                }
            }
        }
        
//        if let messageDict = json.dictionaryObject?["message"] {
//
//            ///Failed to validate token
//            if messageDict as! String == "Failed to validate token" {
//
//                print("MESSAGE: Failed to validate token")
//
//                let queue = DispatchQueue.init(label: "getToken")
//
//                queue.sync {
//
//                       XMNetworking.shareInstance.getLoginToken(param: loginParam, serverUrl: serviceUrl) { (bo) in
//                        XMNetworking.shareInstance.synchronousExpenseReport(postMode: postMode, lineItemCliendIdArr: lineItemCliendIdArr, expenseReport: expenseReport, finished: finished)
//                    }
//                }
//            }
//        }

    }
    
    func GetCookieStorage()->HTTPCookieStorage{
        
        return HTTPCookieStorage.shared
        
    }
    
    func GetCookieArray()->[HTTPCookie]{
        
        let cookieStorage = GetCookieStorage()
        let cookieArray = cookieStorage.cookies
        
        if cookieArray != nil{
            
            return cookieArray!
            
        }else{
            
            return []
            
        }
    }
    
    /// Take some uncertain fields into `jsonString`.
    ///
    /// - Parameters:
    ///   - item: Object that need to be changed, it should be [String: Any].
    ///   - requiredParam: Some fields you do not want to put in `jsonString`.
    /// - Returns: A dictionary with a key for `jsonString`.
    func changeOtherParamToJsonString(item: Any, requiredParam:String...) -> [String: Any] {
        
        var dict:[String: Any] = (item as? [String: Any])!
        var jsonStringDict:[String: Any] = (item as? [String: Any])!
        
        ///Remove unnecessary fields.
        for (k,_) in dict{
            
            if (!requiredParam.contains(k)) {
                
                dict.removeValue(forKey: k)
                
            }
        }
        
        ///Remove required fields
        for i in requiredParam {
            
            jsonStringDict.removeValue(forKey: i)
            
        }
        
        ///Merge two dictionaries
        let jsonString = jsonStringDict.getJSONStringFromDictionary()
        
        dict.updateValue(jsonString, forKey: "jsonString")
        return dict
        
    }
}
