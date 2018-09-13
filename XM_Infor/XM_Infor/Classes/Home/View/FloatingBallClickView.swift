//
//  FloatingBallClickView.swift
//  XM_Infor
//
//  Created by Robin He on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

@objc
protocol FloatingBallClickViewTableViewDelegate:NSObjectProtocol {
    
    @objc optional func FloatingBallClickViewTableViewCellClicked(indexPat:IndexPath)
    
}

class FloatingBallClickView: UIView,FloatingBallDelegate{

    
    var tabV:UITableView?

    var reportFloatingTabV:UITableView?
    
    var isHomeExpenseReportVC = false
    
    var nextVcClosure:((Int)->())?
    
     var cellDict = [["imageName":"credit36","title":"Create New Expense"],["imageName":"credit16","title":"Create New Report"],["imageName":"cards5","title":"Capture a Receipt"]]
    
    var reportDict = [["imageName":"credit36","title":"Attach Expenses"],["imageName":"credit16","title":"Add a New Expense"],["imageName":"cards5","title":"Attach Receipts"]]
    
    let receiptsDict = [["imageName":"credit36","title":"New Expense"],["imageName":"credit16","title":"New Report"],["imageName":"cards5","title":"Capture Receipt"]]
  
    weak var delegate:FloatingBallClickViewTableViewDelegate?
    
     init(frame: CGRect,isHome:Bool) {
        super.init(frame: frame)

        isHomeExpenseReportVC = isHome
        
        FloatingBall.shared.delegate = self
        
        self.backgroundColor = UIColor.black
        self.alpha = 0.3
        tabV = UITableView()
        tabV?.delegate = self
        tabV?.dataSource = self
        tabV?.frame = CGRect(x: getLength(leng: 10), y: 320, width: getLength(leng: 355), height: 180)
        tabV?.isHidden = true
        tabV?.isScrollEnabled = false
        tabV?.layer.cornerRadius = 10
        tabV?.register(UINib.init(nibName: "FloatingBallTabViewCell", bundle: nil), forCellReuseIdentifier: "FloatingBallTabViewCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        self.isHidden = true
        self.tabV?.isHidden = true
        FloatingBall.shared.setBackgroundImage(UIImage(named:"addBtn"), for: .normal)
        FloatingBall.shared.isClick = false
        self.tabV?.y = SCREEN_HEIGHT - getLength(leng: 320)
        self.tabV?.height = 180
  
    }
    
    func FloatingBallClicked(isClick: Bool,isHome: Bool) {
        
        self.isHidden = !isClick
        self.tabV?.isHidden = !isClick
        self.tabV?.y = SCREEN_HEIGHT - getLength(leng: 320)
        self.tabV?.height = 180
        self.tabV?.reloadData()

    }
    
}

extension FloatingBallClickView:FloatingBallTabViewCellDelegate {


    func FloatingBallTabViewCellRightButtonClicked(isUp: Bool) {
        
        if isUp {
            reportDict.append(contentsOf: receiptsDict)
            UIView.animate(withDuration: 0.15, animations: {
                self.tabV?.y = 120
                self.tabV?.height += 180
                 self.tabV?.reloadData()
            })
        } else {
            reportDict.removeSubrange(3...5)
            UIView.animate(withDuration: 0.15, animations: {
                self.tabV?.y = 320
                self.tabV?.height -= 180
                self.tabV?.reloadData()
            })
        }
    }
}

extension FloatingBallClickView:UITableViewDelegate,UITableViewDataSource {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        FloatingBall.shared.isClick = false
        FloatingBall.shared.setBackgroundImage(UIImage(named:"addBtn"), for: [])
        
        self.isHidden = true
        self.tabV!.isHidden = true
        
        if isHomeExpenseReportVC {
            if indexPath.row == 0 {
                let vc = ExpenseTypeVC()
                
                (superview?.next as!UINavigationController).pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {
                let vc = NewExpenseReportViewController()
                (superview?.next as!UINavigationController).pushViewController(vc, animated: true)
            }
        } else {
            if indexPath.row == 0 {
                let nextVC = AttachExpesnesViewController()

                /// get name space
                let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                for vc in (superview?.next as! UINavigationController).childViewControllers {
                    if NSStringFromClass(vc.classForCoder) == namespace + "." + "ExpenseRepoerDetailViewController" {
                       nextVC.expenseReportEKey = (vc as!ExpenseRepoerDetailViewController).expenseReportEKey
                        vc.navigationController?.pushViewController(nextVC, animated: true)
                    }
                }
            }else if indexPath.row == 1 {
                let vc = ExpenseTypeVC()
                (superview?.next as! UINavigationController).pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 60
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isHomeExpenseReportVC {
            
             return cellDict.count
        } else {
        
            return reportDict.count
        
        }
       
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "FloatingBallTabViewCell") as! FloatingBallTabViewCell
        cell.selectionStyle = .none
        cell.delegate = self
       
        if !isHomeExpenseReportVC {
           
            cell.titleImageView.image =  UIImage(named:reportDict[indexPath.row]["imageName"]!)
            cell.titleLabel.text = reportDict[indexPath.row]["title"]
            
            if indexPath.row == 2 {
                cell.rightButton.isHidden = false
            }else{
                cell.rightButton.isHidden = true
            }
        } else {
        
            cell.titleImageView.image =  UIImage(named:cellDict[indexPath.row]["imageName"]!)
            cell.titleLabel.text = cellDict[indexPath.row]["title"]
            cell.rightButton.isHidden = true
        }
        
        
        return cell
    }
}
