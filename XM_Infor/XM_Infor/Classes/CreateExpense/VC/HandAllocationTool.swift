//
//  HandAllocationTool.swift
//  XM_Infor
//
//  Created by Robin He on 02/11/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
class HandAllocationTool: NSObject,AllocationsItemsDelegate {
    var subVC:CreatExpenseVC?
    
    func handAllocationWith(item:ExpenseFieldItem,subVC:CreatExpenseVC,expenseMo:ExpensesModel){
        self.subVC = subVC
        guard let CEView = subVC.CEView else{
            return
        }
        if CEView.AmountTextfield.text == "" {
            CEView.AmountTextfield.text = "0"
//            SVProgressHUD.showInfo(withStatus: "Please write in Amount !")
//            return
        }
        let alloVC = AllocationsViewController()
        alloVC.option = item.option!
        alloVC.delegate = subVC
        alloVC.type = item.type!
        alloVC.totalAmount = subVC.CEView!.AmountTextfield.text!
        alloVC.sunperId = subVC.superClientId
        alloVC.isDataStoreAllocation = subVC.isDataSAllocation // first is false
        alloVC.previousIndexRow = subVC.previousIndexRow ?? -1
    
        if subVC.isExpenseListType == true { // only first go to draft expenselist ,then  isExpenseListType is setted up false
            subVC.isClickCell = true

            let displayDict = expenseMo.displayUI.getDictionaryFromString()
            let jsonStringDict = expenseMo.jsonString.getDictionaryFromString()

            if displayDict["allocationAmounts"] != nil{
                alloVC.isDataStoreAllocation = true
                var expeClientId = ""
                if jsonStringDict["eKey"] != nil{
                    expeClientId = jsonStringDict["eKey"] as! String
                }
                let expenseItem = XMRealm.objects(ExpensesModel.self).filter("eKey = %@",expeClientId).first
                let alloAmounts = expenseItem?.displayUI.getDictionaryFromString()["allocationAmounts"] as!NSMutableArray
                var AmountItemTotal:Float = 0.0
                for Amount in alloAmounts{
                    AmountItemTotal += Float(Amount as! String)!
                }
                subVC.calcurateAllocationAmounts(AmountTotal: AmountItemTotal, alloAmounts: alloAmounts)
                alloVC.percentItems = subVC.percentArray
                alloVC.allocationsDict.setValue(alloAmounts, forKey: "allocationAmounts")
                let alloCSDicItems = expenseItem?.displayUI.getDictionaryFromString()["alloCSDics"] as! [[String:Any]]
                for allodict in alloCSDicItems {
                    let corpModel = CorpDataModel(value: allodict)
                    subVC.allocationCostCenters.append(corpModel)
                }
                alloVC.allocationsDict.setValue(subVC.allocationCostCenters, forKey: "allocationCostCenters")
                let cStrItems = expenseItem?.displayUI.getDictionaryFromString()["allocationColorStrItems"] as! [String]
                alloVC.allocationsDict.setValue(cStrItems, forKey: "allocationColorStrItems")
                let frameStrs = expenseItem?.displayUI.getDictionaryFromString()["subPerLabFrameStrItems"] as! [String]
                alloVC.allocationsDict.setValue(frameStrs, forKey: "allocationSubPerLabFrameItems")
                subVC.navigationController?.pushViewController(alloVC, animated: true)
                subVC.isAgainPrepareDone = true
                
                return
            }else{
                
                if subVC.contentlabItems[0] as!String != ""{
                    subVC.percentArray = [1.0]
                    alloVC._allocation = (jsonStringDict["-allocation"] as!NSArray).firstObject as![String:Any]
                    alloVC.percentItems = subVC.percentArray
                    alloVC.defaultDisplayName = subVC.contentlabItems[0] as!String
                }
                subVC.navigationController?.pushViewController(alloVC, animated: true)
                return
                
            }
        }
        guard subVC.allocationCostCenters.count > 0,
            subVC.allocationColorStrItems.count > 0,
            subVC.allocationAmounts.count > 0
            else { // Allocation has a item
                if subVC.contentlabItems[0] as!String != ""{
                    subVC.percentArray = [1.0]
                    alloVC._allocation = (subVC.enpenseDefaultConfigDic["-allocation"] as!NSArray).firstObject as![String:Any]
                    alloVC.percentItems = subVC.percentArray
                    alloVC.defaultDisplayName = subVC.contentlabItems[0] as!String
                }
                subVC.navigationController?.pushViewController(alloVC, animated: true)
                return
        }
        alloVC.percentItems = subVC.percentArray
        // Allocation has some items
        alloVC.allocationsDict.setValue(subVC.allocationCostCenters, forKey: "allocationCostCenters")
//        if subVC.isAgainPrepareDone {
        if CEView.AmountTextfield.text != "0" {
            var totalRes1:Float = 0.0
            for (i,_) in subVC.allocationAmounts.enumerated() {
                let result =  Float(CEView.AmountTextfield.text!)!
                if subVC.percentArray.count > 0{
                    let amountResult =  String(format:"%.2f%", Float(result * subVC.percentArray[i]))
                    totalRes1 += Float(amountResult)!
                    subVC.allocationAmounts.replaceObject(at: i, with: "\(amountResult)")
                    let resu =  Float(String(format:"%.f%",totalRes1))
                    if i == subVC.allocationAmounts.count - 1 && resu == result{
                        let ddd = result - totalRes1 + Float(amountResult)!
                        subVC.allocationAmounts.replaceObject(at: i, with: "\(ddd)")
                    }
                }
            }
        }
//        }
        alloVC.allocationsDict.setValue(subVC.allocationAmounts, forKey: "allocationAmounts")
        alloVC.allocationsDict.setValue(subVC.allocationColorStrItems, forKey: "allocationColorStrItems")
        alloVC.allocationsDict.setValue(subVC.subPerLabFrameStrItems, forKey: "allocationSubPerLabFrameItems")
        subVC.navigationController?.pushViewController(alloVC, animated: true)
    
    }
    override init() {
      super.init()

    }
    
    
}

