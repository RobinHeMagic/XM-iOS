//
//  HomeTableVC.swift
//  XM_Infor
//
//  Created by Robin He on 03/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class HomeTableVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    let cellIdentifier = "cellIdentifier"
     var myTableView:UITableView?
    var itemArray:NSMutableArray?
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.backgroundColor = UIColor.white
        itemArray = NSMutableArray.init(array: ["北京","上海","天津","深圳","香港","澳门","安徽"])
        
        initView()
    }

    func initView() {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 22/255.0, green: 78/255.0, blue: 127/255.0, alpha: 1.0)
        self.title = "XM"
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.navigationBar.tintColor = nil
        
        myTableView = UITableView(frame:CGRect(x:0,y:0,width:view.frame.size.width,height:view.frame.size.height - 64))
        myTableView?.delegate = self
        myTableView?.dataSource = self
        myTableView?.backgroundColor = UIColor(red:22/255.0 , green:78/255.0 , blue:112/225.0 ,alpha:1.0)
        myTableView?.register(UINib.init(nibName: "FirstFloorTVCell", bundle:nil), forCellReuseIdentifier: "FirstFloorTVCell")
        view.addSubview(myTableView!)
        // regiest second cell
        myTableView?.register(UINib.init(nibName: "SecondFloorTVCell", bundle:nil), forCellReuseIdentifier: "SecondFloorTVCell")
        view.addSubview(myTableView!)
        // regiest third cell
        myTableView?.register(UINib.init(nibName: "ThirdTableViewCell", bundle:nil), forCellReuseIdentifier: "ThirdTableViewCell")
        view.addSubview(myTableView!)
        // regiest fourth cell
        myTableView?.register(UINib.init(nibName: "FourthTableViewCell", bundle:nil), forCellReuseIdentifier: "FourthTableViewCell")
        view.addSubview(myTableView!)
        

    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("\(indexPath.row) ----- ")
        
        if indexPath.row == 2 {
            
            let CV = CreatExpenseVC()
            
            self.navigationController?.pushViewController(CV, animated: true)
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 2 {
            return 100
        }
        return 200
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 4
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int
    {
        return 1
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FirstFloorTVCell")!
            cell.backgroundColor = UIColor(red:22/255.0 , green:78/255.0 , blue:112/225.0 ,alpha:1.0)
            
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SecondFloorTVCell")!
            cell.backgroundColor = UIColor(red:22/255.0 , green:78/255.0 , blue:112/225.0 ,alpha:1.0)
            cell.selectionStyle = .none
            return cell
            
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ThirdTableViewCell")!
            cell.backgroundColor = UIColor(red:22/255.0 , green:78/255.0 , blue:112/225.0 ,alpha:1.0)
            cell.selectionStyle = .none
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "FourthTableViewCell")!
            cell.backgroundColor = UIColor(red:22/255.0 , green:78/255.0 , blue:112/225.0 ,alpha:1.0)
            cell.selectionStyle = .none
            return cell
            
        }
     
    }

}
