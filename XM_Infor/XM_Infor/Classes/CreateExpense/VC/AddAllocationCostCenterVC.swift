//
//  AddAllocationCostCenterVC.swift
//  XM_Infor
//
//  Created by Robin He on 11/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class AddAllocationCostCenterVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var costCenterTabView:UITableView?
    var CostCenterItems = [CorpDataModel]()
    
    var corpDataTypeId = 0
    var storageCorpDataItems = [CorpDataModel]()
    
    var option = 0
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        title = "Add Cost Center"
        
        let item1 = UIBarButtonItem(title:"Back",style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
        navigationItem.leftBarButtonItem = item1
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        let firstView = AddExpenseTypeFirstView(frame:CGRect(x: 0, y: 0, width: view.bounds.width, height: 120),bySearch:true,isCostCenter:true)
        firstView.option = option
        firstView.LocationCallback = {[weak self](Items) in
            
            self?.CostCenterItems = Items as! [CorpDataModel]
            self?.costCenterTabView?.reloadData()
        }
        view.addSubview(firstView)
        
        costCenterTabView = UITableView(frame:CGRect(x: 0, y: 120, width: view.bounds.width, height: view.bounds.height - 185))
        costCenterTabView?.delegate = self
        costCenterTabView?.dataSource = self
        costCenterTabView?.register(UINib.init(nibName: "AddExpenseTypeTVCell", bundle: nil), forCellReuseIdentifier: "AddExpenseTypeTVCell")
        costCenterTabView?.rowHeight = 65
        view.addSubview(costCenterTabView!)
        
        storageCorpDataItems = Storage.shareStorage.queryCorpDataModelsByCorpDataTypeName(corpDataTypeName: type)
    
    }
}

extension AddAllocationCostCenterVC{

    func cancelClick(){
            navigationController?.popViewController(animated: true)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if storageCorpDataItems.count > 0 && CostCenterItems.count == 0 {
            
            return storageCorpDataItems.count
        }
        return self.CostCenterItems.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if storageCorpDataItems.count > 0 && CostCenterItems.count == 0 {
            
            postNotificationName(name: "CostCenterNotification", andUserInfo: ["CostCenterModel":self.storageCorpDataItems[indexPath.row]])

        }

        if CostCenterItems.count > 0 {
           
            postNotificationName(name: "CostCenterNotification", andUserInfo: ["CostCenterModel":self.CostCenterItems[indexPath.row]])
            
             Storage.shareStorage.setCorporDataToMRUByTypeName(corpDataTypeName: type, corpData: self.CostCenterItems[indexPath.row])
        }
        
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddExpenseTypeTVCell")! as! AddExpenseTypeTVCell
         cell.allocationTypeLabel.isHidden = false
        if CostCenterItems.count > 0 {
            cell.locationLabel.text = self.CostCenterItems[indexPath.row].displayName
            if self.CostCenterItems[indexPath.row].jsonString.getDictionaryFromString()["type"] as!Int == 29500{
                cell.allocationTypeLabel.text = "costCenter"
            } else {
                cell.allocationTypeLabel.text = "projectNumber"
            }
        } else if storageCorpDataItems.count > 0 {
            cell.locationLabel.text = self.storageCorpDataItems[indexPath.row].displayName
            if self.storageCorpDataItems[indexPath.row].jsonString.getDictionaryFromString()["type"] as!Int == 29500{
                cell.allocationTypeLabel.text = "costCenter"
            } else {
                cell.allocationTypeLabel.text = "projectNumber"
            }
        }
        return cell
    }





}
