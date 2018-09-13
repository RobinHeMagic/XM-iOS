//
//  LoginVC.swift
//  XM_Infor
//
//  Created by Robin He on 26/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initNav()
        initView()
//        self.edgesForExtendedLayout = .bottom
    }
    func initNav(){
        
        title = "XM"
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
//        navigationController?.navigationBar.setBackgroundImage(UIImage(named:"navigationBarBG"), for: .default)
//        print(navigationController?.navigationBar.subviews[0])
//    navigationController?.navigationBar.subviews[0].layer.insertSublayer(getGradientColorGradientLayer3(view:navigationController!.navigationBar.subviews[0]), at: 0)
        navigationController?.navigationBar.barTintColor = UIColor.colorWithHexString("2f5e7b")
        navigationController?.navigationBar.isTranslucent = false
        let dict:NSDictionary = [NSForegroundColorAttributeName: UIColor.white,NSFontAttributeName : UIFont.boldSystemFont(ofSize: 18)]
        
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [String : AnyObject]
        view.backgroundColor = UIColor.white
    }
    func initView()  {
        let loview = LoginView.XibLoginView()
        loview.frame = self.view.frame
        view.addSubview(loview)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }


}
