//
//  AddExpenseTypeVC.swift
//  XM_Infor
//
//  Created by 何兵兵 on 2017/7/8.
//  Copyright © 2017年 Robin He. All rights reserved.
//

import UIKit

class AddExpenseTypeVC: XMBaseViewController{

    var tableView:UITableView?
    var locationItems = [CorpDataModel]()
    var itemArray = [CorpDataModel]() // There is not bySearch
    var bySearch = 0
    var corpDataTypeId = 0
    var type = ""
    
    var storageCorpDataItems = [CorpDataModel]()
    var expenseType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNav()
        initView()
        setData()
        
    }
    deinit {
        print("AddExpenseTypeVC被销毁了～")
    }
}


extension AddExpenseTypeVC{
    
    func setData() {
        if bySearch == 0 && type != ""{
            Storage.shareStorage.corporData(type: type, finished: { [weak self](expenseItems) in
                if expenseItems.count > 0 { //
                    self?.itemArray = expenseItems
                    self?.tableView?.reloadData()
                }
            })
        }
        if bySearch != 0 && type != ""{
           storageCorpDataItems = Storage.shareStorage.queryCorpDataModelsByCorpDataTypeName(corpDataTypeName: type)
        }
        
    }
    func setNav() {
        let item3=UIBarButtonItem(image:UIImage(named:"left46"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(showPrevious))
        navigationItem.leftBarButtonItem =  item3
        view.backgroundColor = UIColor.white
    }
    func showPrevious() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    func initView() {
        
        if bySearch == 0 {

            tableView = UITableView(frame:CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: view.bounds.height))
        } else {
            let firstView = AddExpenseTypeFirstView(frame:CGRect(x: 0, y: 0, width: view.bounds.width, height: 120),bySearch:true,isCostCenter:false)
            firstView.type = type
            view.addSubview(firstView)
            firstView.LocationCallback = {[weak self](Items) in
                self?.locationItems = Items as! [CorpDataModel]
                self?.tableView?.reloadData()
            }
            tableView = UITableView(frame:CGRect(x: 0, y: 120, width: SCREEN_WIDTH, height: view.bounds.height - 180))
        }
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(UINib.init(nibName: "AddExpenseTypeTVCell", bundle: nil), forCellReuseIdentifier: "AddExpenseTypeTVCell")
        tableView?.rowHeight = 65
        view.addSubview(tableView!)
        
    }
    
}

extension AddExpenseTypeVC:UITableViewDelegate,UITableViewDataSource {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         view.endEditing(true)
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let  cell =  tableView.cellForRow(at: indexPath) as! AddExpenseTypeTVCell
        if locationItems.count > 0 || itemArray.count > 0 { // bySearch == 0 or bySearch == 1
            postNotificationName(name: "LocationNotification", andUserInfo: ["totalStr":cell.locationLabel.text ?? "","id":self.locationItems.count > 0 ? locationItems[indexPath.row].uid : itemArray[indexPath.row].uid])
        }
        if storageCorpDataItems.count > 0 && locationItems.count == 0{ // local data and there is not search data
             postNotificationName(name: "LocationNotification", andUserInfo: ["totalStr":cell.locationLabel.text ?? "","id":storageCorpDataItems[indexPath.row].uid])
        }
        if locationItems.count > 0{ // store data
            Storage.shareStorage.setCorporDataToMRUByTypeName(corpDataTypeName: type, corpData: self.locationItems[indexPath.row])
        }
        showPrevious()
        
    }
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bySearch == 0 && type != "" {
          return itemArray.count
        } else if storageCorpDataItems.count > 0 && locationItems.count == 0{
          return storageCorpDataItems.count
        }
          return locationItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddExpenseTypeTVCell")! as! AddExpenseTypeTVCell
        if locationItems.count > 0 {
           cell.locationLabel.text = locationItems[indexPath.row].displayName
        } else if itemArray.count > 0 {
           cell.locationLabel.text = itemArray[indexPath.row].displayName
        } else if storageCorpDataItems.count > 0 {
           cell.locationLabel.text = storageCorpDataItems[indexPath.row].displayName
        }
          return cell
       }

}
