//
//  HaveFloatBallBaseVC.swift
//  XM_Infor
//
//  Created by Robin He on 01/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class HaveFloatBallBaseVC: UIViewController,FloatingBallClickViewTableViewDelegate{

    var isHome = false
    
    lazy var FBView:FloatingBallClickView = {
        
        let FBV = FloatingBallClickView(frame: UIScreen.main.bounds, isHome: self.isHome)
    
        FBV.isHidden = true
        
        return FBV
    }()
    
    
   dynamic override func viewWillDisappear(_ animated: Bool) {
        
        let fball = FloatingBall.shared
        fball.isHidden = true
        FBView.isHomeExpenseReportVC = true
    }
    
   dynamic override func viewWillAppear(_ animated: Bool) {
    
        let fball = FloatingBall.shared
        fball.isHidden = false
        FBView.isHomeExpenseReportVC = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let vc = UIApplication.shared.keyWindow?.rootViewController?.view else {
            return
        }
      
        let item1 = UIBarButtonItem(title:"Back",style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
        navigationItem.leftBarButtonItem = item1
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white

        FBView.delegate = self
        vc.addSubview(FBView)
        vc.addSubview(FBView.tabV!)
        vc.addSubview(FloatingBall.shared)
        
    }
    
    
    dynamic func cancelClick() {
        
//        self.FBView.isHomeExpenseReportVC = true
        self.navigationController?.popViewController(animated: true)
    }

}
