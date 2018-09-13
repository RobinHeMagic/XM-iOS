//
//  XMNetworking.swift
//  XMAPP
//
//  Created by Jeremy Wang on 04/07/2017.
//  Copyright © 2017 Jeremy Wang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import RealmSwift
import SVProgressHUD

//let serviceUrl = "http://10.86.24.60:7001/xm-api/v1/application/"

var  token = ""
var defaultParam = [String:String]()

class XMNetworking: NSObject {
    
static let shareInstance = XMNetworking()
 
    func getLoginToken(param:Parameters,serverUrl:String,finished:@escaping (_ isSuccess: Bool) -> ()){
        defaultParam.updateValue(param["userId"] as!String, forKey: "userId")
        loginParam = param
        serviceUrl = serverUrl
        
        let urlStr = "\(serverUrl)Token?xmenv=true"
        let url = URL(string: urlStr)
        var urlRequest = URLRequest(url: url!)
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: [])
        } catch {
            print(error)
        }
        
        Session.sharedInstance.ApiManager().request(urlRequest).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleToken(value: returnResult.result.value as Any, finished: finished)
                }
            case.failure(let error):
                print(error)
                finished(false)
            }
        }
    }
    
    func getCorpData(type: String, finished: @escaping (_ corpDataItems: [CorpDataModel]) -> ()) {
        let urlStr = getURLString(type: type, param: "")
        Session.sharedInstance.ApiManager().request(urlStr, method: .get, parameters: defaultParam).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleCorpData(value: returnResult.result.value as Any, type: type, finished: finished)
                }
            case.failure(let error):
                print(error)
                finished(Storage.shareStorage.queryCorpDataModelsByCorpDataTypeName(corpDataTypeName: type))
            }
        }
    }
    
    func getCorporateDataBySearch(type: String, keyWord: String, finished: @escaping (_ corpDataItems: [CorpDataModel]) -> ()) {
        let urlStr = getURLString(type: type, param: "&query=\(keyWord)")
        Session.sharedInstance.ApiManager().request(urlStr, method: .get, parameters: defaultParam).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleCorporateDataBySearch(value: returnResult.result.value as Any, keyWord: keyWord, type: type, finished: finished)
                }
            case.failure(let error):
                print(error)
                
            }
        }
    }

    func getExpenseReportForm(purposeId: Int, finished:@escaping (_ fieldItems: [String: Any]) -> ()) {
        let urlStr = getURLString(type: "ExpenseReportForm", param: "&purposeId=\(purposeId)")
        Session.sharedInstance.ApiManager().request(urlStr, method: .get, parameters: defaultParam).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleExpenseReportForm(purposeId: purposeId, value: returnResult.result.value as Any, finished: finished)
                }
            case.failure(let error):
                finished(Storage.shareStorage.queryExpenseReportFormModelBy(purposeId: purposeId))
                print(error)
            }
        }
    }
        
    func getExpenseLineItemTemp(expenseTypeId: Int, needReference: Bool, finished:@escaping (_ fieldItems: [[String: Any]]) -> ()) {
        var urlStr = getURLString(type: "ExpenseLineItem", param: "&newLineItem=1&metadata=1&expenseTypeId=\(expenseTypeId)")
        if needReference {
            urlStr+="&reference=1"
        }
        Session.sharedInstance.ApiManager().request(urlStr, method: .get, parameters: defaultParam).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleExpenseLineItemTemp(value: returnResult.result.value as Any, expenseTypeId: expenseTypeId, needReference: needReference, finished: finished)
                }
            case.failure(let error):
                finished(Storage.shareStorage.queryExpenseLineItemTempMetadataBy(expenseTypeId: expenseTypeId))
                print(error)
            }
        }
    }
    
    func getChargeCode(project: Bool, costCenter: Bool,query: String, finished: @escaping (_ chargeCodeItems: [CorpDataModel]) -> ()) {
        var urlStr = getURLString(type: "ChargeCode", param: "")
        var param: Parameters = ["query": query]
        param.merge(dict: defaultParam)
        
        if project {
            urlStr+="&projectNumber=1"
        }
        if costCenter {
            urlStr+="&costCenter=1"
        }
        
        Session.sharedInstance.ApiManager().request(urlStr, method: .get, parameters: param).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleChargeCode(value: returnResult.result.value as Any, project: project, costCenter: costCenter, finished: finished)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func getBObID(max: Int) {
        let urlStr = getURLString(type: "BObID", param: "&max=\(max)")
        Session.sharedInstance.ApiManager().request(urlStr, method: .get, parameters: defaultParam).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleBObID(value: returnResult.result.value as Any, max: max)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func getExpenselineItem(isCC: Bool, isReference: Bool, finished:@escaping (_ ccExpenseLineItems: [ExpensesModel]) -> ()) {
        var urlStr = getURLString(type: "ExpenseLineItem", param: "&userId=\(defaultParam["userId"]!)")
        
        if isCC { //&reference=1
            urlStr+="&unattachedCCT=1"
        }
        if isReference {
            urlStr+="&reference=1"
        }
        
        Session.sharedInstance.ApiManager().request(urlStr, method: .get, parameters: defaultParam).responseJSON { (returnResult) in
            switch returnResult.result{
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleExpenseLineItem(value: returnResult.result.value as Any, isCC: isCC, isReference: isReference, finished: finished)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func postExpenseLineItem(postMode: String, expense: [String: Any], finished: @escaping (_ isSuccess: Bool) -> ()) {
        let param: Parameters = expense
        let urlStr = getURLString(type: "ExpenseLineItem", param: "&validateOnly=1&userId=\(defaultParam["userId"]!)")
        let url = URL(string:urlStr)
        var urlRequest = URLRequest(url:url!)
        
        urlRequest.timeoutInterval = 10
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: [])
        } catch {
            print(error)
        }

        Session.sharedInstance.ApiManager().request(urlRequest).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    XMHandleJSON().handleLineItemPost(postMode: postMode, expense: expense, value: returnResult.result.value as Any, finished: finished)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func postReceiptItem(receiptDit:[String:Any],finished:@escaping (_ isSuccess: Bool) -> ()) {
        let param: Parameters = receiptDit
        let urlStr = getURLString(type: "Receipt", param: "&userId=\(defaultParam["userId"]!)")
        
        let url = URL(string:urlStr)
        var urlRequest = URLRequest(url:url!)
        
        urlRequest.timeoutInterval = 10
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: [])
        } catch {
            print(error)
        }
        Session.sharedInstance.ApiManager().request(urlRequest).responseJSON { (returnResult) in
            switch returnResult.result {
            case.success:
                if returnResult.response?.statusCode == 200 {
                    print("post Successful!")
                    finished(true)
                    print(returnResult)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    func synchronousExpenseReport(postMode: String, lineItemEKeyArr: Array<String>, expenseReport: [String: Any], finished:@escaping (_ isSuccess: Any) -> ()) {
        let param: Parameters = expenseReport
        let urlStr = getURLString(type: "ExpenseReport", param: "&submitDocument=1&userId=\(defaultParam["userId"]!)")
        
        let url = URL (string: urlStr)
        var urlRequest = URLRequest (url: url!)
        
        urlRequest.timeoutInterval = 10
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: param, options: [])
        } catch {
            print(error)
        }
        
        let returnResult = Session.sharedInstance.ApiManager().request(urlRequest).responseJSON()
        
        print(returnResult)
        
        switch returnResult.result {
            
        case.success:
            if returnResult.response?.statusCode == 200 {
                
                XMHandleJSON().handleExpenseReport(postMode: postMode, lineItemEKeyArr: lineItemEKeyArr, expenseReport: expenseReport, value: returnResult.value as Any, finished: finished)
            }
            
        case.failure(let error):
            networkFailed()
            print(error)
        }
    }
    
    func getDeviceID() -> String {
        return (UIDevice.current.identifierForVendor?.uuidString)!
    }
    
    func getEkey() -> String {
        let deviceID = getDeviceID()
        let hexDateStr = String().appendingFormat("%X",Int(NSDate().timeIntervalSince1970))
        return "\(deviceID)+\(hexDateStr)+\(arc4random() % 99999999)"
    }

    func getURLString(type: String, param: String) -> String {
        return "\(serviceUrl)\(type)?xmenv=true&token=\(token)" + param
    }
    
    func networkFailed() {
        SVProgressHUD.showError(withStatus: "Network connection failed")
        SVProgressHUD.dismiss(withDelay: 0.8)
    }
}

class Session {
    static let sharedInstance = Session()
    
    private var manager : SessionManager?
    
    func ApiManager()->SessionManager{
        if let m = self.manager{
            return m
        }else{
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 10
            let tempManager = Alamofire.SessionManager(configuration: configuration)
            self.manager = tempManager
            return self.manager!
        }
    }
}

/// Put postExpenseReport in runloop
final class ExpenseReportSingleTon {
    static let shareSingleTon = ExpenseReportSingleTon()
    
    let networkManager = NetworkReachabilityManager(host: "10.86.24.60")
    
    let timer_postLineItem = Timer (timeInterval: 10, repeats: true) { (timer) in
        
        let draftLineItems = Storage.shareStorage.queryExpensesModelBySuperEKeyAndStatusAndLock(superEKey: "", status: "draft", lock: false)

        if draftLineItems.count > 0 {
            
            for item in draftLineItems {
                let postDict: [String: Any] = item.jsonString.getDictionaryFromString() as! [String: Any]
                
                XMNetworking.shareInstance.postExpenseLineItem(postMode: "validateOnly", expense: postDict, finished: { (isSuccess) in
                    if isSuccess {
                    
                        NotificationCenter.default.post(name: NSNotification.Name (rawValue: "updateMyExpenseListData"), object: nil)
                        
                    }else{
                        
                    }
                })
            }
        }
        if UserDefaults.standard.value(forKey: "receiptDict") != nil{
            let receiptDict = UserDefaults.standard.value(forKey: "receiptDict") as![String:Any]
            XMNetworking.shareInstance.postReceiptItem(receiptDit: receiptDict, finished: { result in
                if result == true {
                  NotificationCenter.default.post(name: NSNotification.Name (rawValue: "uploadReceiptNoti"), object: nil)
                }
            })
        }
    }

    private init() {
        
        DispatchQueue.global().async {
            RunLoop.main.add(self.timer_postLineItem, forMode: RunLoopMode.commonModes)
            
            self.networkManager?.listener = { status in
                switch status {
                case .notReachable:
                    print("Network -- NotReachable")
                    networkStatus = false
                    self.timerStop()
                    
                case .unknown:
                    print("Network -- Unknown")
                    networkStatus = false
                    self.timerStop()
                    
                case .reachable(.ethernetOrWiFi):
                    print("Network -- EthernetOrWifi")
                    networkStatus = true
                    self.timerStart()
                    
                case .reachable(.wwan):
                    print("Network -- WWAN")
                    networkStatus = true
                    self.timerStart()
                }
            }
        }
    }
    
    func timerStop(){
        timer_postLineItem.fireDate = Date.distantFuture
    }

    func timerStart() {
        timer_postLineItem.fireDate = Date.distantPast
    }

}
