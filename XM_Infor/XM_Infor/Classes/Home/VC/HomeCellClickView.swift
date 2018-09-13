//
//  HomeCellClickView.swift
//  XM_Infor
//
//  Created by Robin He on 15/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class HomeCellClickView: UIView,UITableViewDelegate,UITableViewDataSource{
  
    let cellHelpItems = ["Confirm BRV","Edit"]
    var originY:CGFloat = 0
    var jsonString = ""

    var cellHelpTabv:UITableView?
    var expenseModel:ExpensesModel?
    
    init(frame: CGRect,originY:CGFloat) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        cellHelpTabv = UITableView()
        cellHelpTabv?.x = 10
        cellHelpTabv?.y = originY
        cellHelpTabv?.width = SCREEN_WIDTH - 20
        cellHelpTabv?.height = 100
        cellHelpTabv?.delegate = self
        cellHelpTabv?.dataSource = self
        cellHelpTabv?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        cellHelpTabv?.isScrollEnabled = false
        cellHelpTabv?.layer.borderWidth = 0.5
        cellHelpTabv?.layer.cornerRadius = 5
        cellHelpTabv?.layer.borderColor = UIColor.clear.cgColor
        cellHelpTabv?.clipsToBounds = true
        self.alpha = 0.3
        self.backgroundColor = UIColor.black

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cellHelpItems[indexPath.row]
        cell.textLabel?.textColor = UIColor.black
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0 {
            let vc = BusinessRuleVC()
            vc.expenseModel = expenseModel
            (superview?.next as!UINavigationController).pushViewController(vc, animated: true)
        } else {
            let vc = CreatExpenseVC()
            vc.expenseModel = expenseModel
            vc.isExpenseListType = true
            (superview?.next as!UINavigationController).pushViewController(vc, animated: true)
        }
        cellHelpTabv?.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        cellHelpTabv?.removeFromSuperview()
        self.removeFromSuperview()
//        self.removeFromParentViewController()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
