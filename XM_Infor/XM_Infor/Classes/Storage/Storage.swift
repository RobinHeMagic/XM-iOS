//
//  Storage.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 31/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class Storage: NSObject {
    
    static let shareStorage = Storage()
    
    //********************Network***********************
    func login(param:Parameters,serverUrl:String,finished:@escaping (_ isSuccess: Bool) -> ()) {
        XMNetworking.shareInstance.getLoginToken(param: param, serverUrl: serverUrl, finished: finished)
    }
    
    func corporData(type: String, finished: @escaping (_ corpDataItems: [CorpDataModel]) -> ()) {
        XMNetworking.shareInstance.getCorpData(type: type, finished: finished)
    }
    
    func corporDataBySearch(type: String, keyWord: String, finished: @escaping (_ corpDataItems: [CorpDataModel]) -> ()) {
        XMNetworking.shareInstance.getCorporateDataBySearch(type: type, keyWord: keyWord, finished: finished)
    }

    func ccExpenseLineItem(isReference: Bool, finished:@escaping (_ ccExpenseLineItems: [ExpensesModel]) -> ()) {
        XMNetworking.shareInstance.getExpenselineItem(isCC: true, isReference: isReference, finished: finished)
    }
    
    func expenseLineItemTemp(expenseTypeId: Int, needReference: Bool, finished: @escaping (_ fieldItems: [[String: Any]]) -> ()) {
        XMNetworking.shareInstance.getExpenseLineItemTemp(expenseTypeId: expenseTypeId, needReference: needReference, finished: finished)
    }
    
    func expenseReportTemp(purpose: Int, finished:@escaping (_ fieldItems: [String: Any]) -> ()) {
        XMNetworking.shareInstance.getExpenseReportForm(purposeId: purpose, finished: finished)
    }
    
    /// Get project and cost center.
    ///
    /// - Parameters:
    ///   - project: fill in "true" if need or "false" if not;
    ///   - costCenter: fill in "true" if need or "false" if not;
    ///   - query: fill in keywords;
    ///   - finished: An array of CorpDataModel.
    func chargeCode(project: Bool, costCenter: Bool, query: String, finished: @escaping (_ chargeCodeItems: [CorpDataModel]) -> ()) {
        XMNetworking.shareInstance.getChargeCode(project: project, costCenter: costCenter, query: query, finished: finished )
    }

    func bobID(max: Int)  {
        XMNetworking.shareInstance.getBObID(max: max)
    }
    
    func expenseReport(postMode: String, lineItemEKeyArr: Array<String>, expenseReport: [String: Any], finished:@escaping (_ isSuccess: Any) -> ()) {
        XMNetworking.shareInstance.synchronousExpenseReport(postMode: postMode, lineItemEKeyArr: lineItemEKeyArr, expenseReport: expenseReport, finished: finished)
    }
    
    func takeEKey() -> String {
        return XMNetworking.shareInstance.getEkey()
    }
    
    /// Create a new expense report with expense report header information and return its eKey.
    ///
    /// - Parameter infor: Expener report header information.
    /// - Returns: Expense report eKey.
    func createExpenseReportWithInformation(infor: [String: Any]) -> String {
        var er: [String: Any] = ["eKey": takeEKey(), "status": "draft", "createDate": nowNormalDateString()]
        let expenseReport = ExpenseReportModel()
        
        er.merge(dict: infor)
        expenseReport.write(er: er)
        Storage.shareStorage.saveOrUpdateData(model: expenseReport)
        return expenseReport.eKey
    }
    
    //*******************Update Realm*****************
    
    func saveOrUpdateData(model: Object) {
        try! XMRealm.write {
            XMRealm.add(model, update: true)
        }
    }
    
    func deleteData(model: Object) {
        try! XMRealm.write {
            XMRealm.delete(model)
        }
    }
    
    func saveExpense(expenseDict: [String: Any], releaseLock: Bool) {
        let expenseModel = ExpensesModel()
        expenseModel.dictionaryWith(expense: expenseDict)
        expenseModel.lock = releaseLock
        saveOrUpdateData(model: expenseModel)
    }
    
    //*********************BObIDModel*********************
    
    /// Take an BObID from `Realm` then delete it, if the total number of BObIDs is less than 20, it will request to add to 100 automatic.
    ///
    /// - Returns: BObID
    func takeBObID() -> Int {
        let models = XMRealm.objects(BObIDModel.self)
        deleteData(model: models[0])
        if models.count < 20 {
            bobID(max: 100 - models.count)
        }
        return models[0].uid
    }
    
    //*********************CorpDataModel*********************
    
    /// When user choose a `CorporateData` item, cache it.
    ///
    /// - Parameters:
    ///   - corpDataTypeId: CorpDataTypeId.
    ///   - corpData: User seleted item.
    func setCorporDataToMRUByTypeName(corpDataTypeName: String, corpData: CorpDataModel) {
        let corpDataItem = corpData
        corpDataItem.typeName = corpDataTypeName
        try! XMRealm.write {
            XMRealm.add(corpDataItem, update: true)
        }
    }
    
    func queryCorpDataModelsByCorpDataTypeName(corpDataTypeName: String) -> [CorpDataModel] {
        let corpDataList = XMRealm.objects(CorpDataModel.self).filter("typeName = %@", corpDataTypeName)
        var corpDataItems = [CorpDataModel]()
        for item in corpDataList {
            corpDataItems.append(item)
        }
        return corpDataItems
    }
    
    //*********************CorpDataTimeoutModel*********************
    
//    func queryCorpDataTimeOutModel(corpDataTypeId: Int) -> CorpDataTimeoutModel {
//        let corpDataTimeOutList = XMRealm.objects(CorpDataTimeoutModel.self).filter("corpDataTypeId = %@", corpDataTypeId)
//        var corpDataTOMItem = CorpDataTimeoutModel()
//
//        if corpDataTimeOutList.count > 0 {
//            corpDataTOMItem = corpDataTimeOutList[0]
//        }else{
//            corpDataTOMItem.date = 0.0
//            corpDataTOMItem.corpDataTypeId = corpDataTypeId
//        }
//
//        return corpDataTOMItem
//    }
    
    func queryCorpDataTimeOutModelBy(corpDataTypeName: String) -> CorpDataTimeoutModel {
        let corpDataTimeOutList = XMRealm.objects(CorpDataTimeoutModel.self).filter("corpDataTypeName = %@", corpDataTypeName)
        var corpDataTOMItem = CorpDataTimeoutModel()
        
        if corpDataTimeOutList.count > 0 {
            corpDataTOMItem = corpDataTimeOutList[0]
        }else{
            corpDataTOMItem.date = 0.0
            corpDataTOMItem.corpDataTypeName = corpDataTypeName
        }
        
        return corpDataTOMItem
    }
    
    //*********************ExpenseLineItemTempModel*********************
    func queryExpenseLineItemTempMetadataBy(expenseTypeId: Int) -> [[String: Any]] {
        let expenseLineItemTemps = XMRealm.objects(ExpenseLineItemTempModel.self).filter("expenseTypeId = %@", expenseTypeId)
        if expenseLineItemTemps.count > 0 {
            let expenseLineItemTemp = expenseLineItemTemps[0]
            
            let metadata = expenseLineItemTemp.jsonString.getDictionaryFromString()["-metadata"] as! [String: [String: Any]]
            var fieldArr: [[String: Any]] = []
            
            for (_, value) in metadata {
                fieldArr.append(value)
            }
            
            return fieldArr.sorted(by: { (t1, t2) -> Bool in
                return (t1["order"] as! Int) < (t2["order"] as! Int) ? true: false
            })
        }
        return [[String: Any]()]
    }
    
    func queryExpenseLineItemTempFieldsNameArr(expenseTypeId: Int) -> [String] {
        let metadata = queryExpenseLineItemTempMetadataBy(expenseTypeId: expenseTypeId)
        var nameArr = [String]()
        
        for item in metadata {
            if (item["name"] as! String) != "date" && (item["name"] as! String) != "expenseType" && (item["name"] as! String) != "nativeAmount" {
                nameArr.append(item["name"] as! String)
            }
        }
        return nameArr
    }
    //*********************ExpenseReportFormModel*********************
    func queryExpenseReportFormFieldBy(purposeId: Int, fieldName: String) -> [String] {
        var resultArr = [String]()
        
        let expenseReportForm = XMRealm.objects(ExpenseReportTempModel.self).filter("purposeId = %@", purposeId)
        let dict: [String: Any] = expenseReportForm[0].jsonString.getDictionaryFromString() as! [String : Any]
        let fields: Array<[String: Any]> = dict["fields"] as! Array<[String: Any]>
        for item in fields {
            resultArr.append(item[fieldName] as! String)
        }
        
        return resultArr
    }
    
    func queryExpenseReportFormModelBy(purposeId: Int) -> [String: Any] {
        return XMRealm.objects(ExpenseReportTempModel.self).filter("purposeId = %@", purposeId)[0].jsonString.getDictionaryFromString() as! [String: Any]
    }
    
    func queryExpenseReportFormArrayBy(purposeId: Int) -> Array<[String: Any]> {
        let expenseReportForm = XMRealm.objects(ExpenseReportTempModel.self).filter("purposeId = %@", purposeId)
        let dict: [String: Any] = expenseReportForm[0].jsonString.getDictionaryFromString() as! [String : Any]
        let fields: Array<[String: Any]> = dict["fields"] as! Array<[String: Any]>
        return fields
    }
    
    //*********************ExpenseReportModel*********************
    
    func queryExpenseReportModel(eKey: String) -> ExpenseReportModel {
        let expenseReportList = XMRealm.objects(ExpenseReportModel.self).filter("eKey = %@", eKey)
        return expenseReportList[0]
    }
    
    func queryAllExpenseReports() ->Results<ExpenseReportModel> {
        return XMRealm.objects(ExpenseReportModel.self)
    }
    
     func updateExpensesReportWithEKey(eKey: String,andExpenseReportDict dict:[String:Any]) {
        let expenseReport = Storage.shareStorage.queryExpenseReportModel(eKey: eKey)
        try!XMRealm.write {
            for (key,value) in dict{
                expenseReport.setValue(value, forKey: key)
            }
        }
    }
    
    func deleteExpenseReportModel(eKey: String) {
        let expenseReportList = XMRealm.objects(ExpenseReportModel.self).filter("eKey = %@", eKey)
        deleteData(model: expenseReportList[0])
    }
    
    //*********************ExpensesModel*********************
    
    func queryExpensesModelByEKey(eKey: String, applyLock: Bool) -> ExpensesModel? {
        let expensesList = XMRealm.objects(ExpensesModel.self).filter("eKey = %@", eKey)
        if applyLock && expensesList[0].lock {
            return nil
        }else{
            try! XMRealm.write {
                expensesList[0].lock = applyLock
            }
            return expensesList[0]
        }
    }
    
    func queryExpensesModelBySuperEKey(superEKey: String) -> Results<ExpensesModel> {
        return XMRealm.objects(ExpensesModel.self).filter("superEKey = %@", superEKey)
    }
    
    func queryExpensesModelBySuperEKeyAndStatusAndLock(superEKey: String, status: String, lock: Bool) -> Results<ExpensesModel> {
        return XMRealm.objects(ExpensesModel.self).filter("superEKey = %@ AND status = %@ AND lock = %@", superEKey, status, lock)
    }
    
    func queryExpensesModelByStatus(status: String) -> Results<ExpensesModel> {
        return XMRealm.objects(ExpensesModel.self).filter("status = %@", status)
    }
    
    func queryOutOfPocketExpensesModelBy(status: String) -> Results<ExpensesModel> {
        return XMRealm.objects(ExpensesModel.self).filter("status = %@ AND NOT jsonString CONTAINS %@", status, "ccTransactionId")
    }
    
    func queryCorporateCardExpenseModelBy(status: String) -> Results<ExpensesModel> {
        return XMRealm.objects(ExpensesModel.self).filter("jsonString CONTAINS %@ AND status = %@", "ccTransactionId", status)
    }
    
    func queryAllExpenseModels() -> Results<ExpensesModel> {
        return XMRealm.objects(ExpensesModel.self)
    }
    
    func updateExpensesModelWithEKey(eKey: String,andExpenseDict dict:[String:Any]) {
        let expenseItem = Storage.shareStorage.queryExpensesModelByEKey(eKey: eKey, applyLock: false)
        try!XMRealm.write {
            for (key,value) in dict{
                expenseItem?.setValue(value, forKey: key)
            }
        }
    }
    
    func releaseLocksForAllExpenses() {
        try! XMRealm.write {
            for item in queryAllExpenseModels() {
                item.lock = false
            }
        }
    }
    
    func deleteExpensesModel(eKey: String) {
        let expensesList = XMRealm.objects(ExpensesModel.self).filter("eKey = %@", eKey)
        deleteData(model: expensesList[0])
    }
}

extension UserDefaults {
    
    struct Token: UserDefaultsSettable {
        enum defaultKeys: String {
            case token
        }
    }
}

protocol UserDefaultsSettable {
    associatedtype defaultKeys: RawRepresentable
}

// MARK: - Using the "where" to restrict the association type is a string type.
extension UserDefaultsSettable where defaultKeys.RawValue==String {
    
    static func set(value: String, forKey key:defaultKeys) {
        let aKey = key.rawValue
        UserDefaults.standard.set(value, forKey: aKey)
    }
    
    static func string(forKey key:defaultKeys) -> String {
        let aKey = key.rawValue
        return UserDefaults.standard.string(forKey: aKey)!
    }
    
}
extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        return flatMap { $0 as? T }
    }
}
