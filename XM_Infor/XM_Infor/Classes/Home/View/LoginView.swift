//
//  LoginView.swift
//  XM_Infor
//
//  Created by Robin He on 26/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import SVProgressHUD
class LoginView: UIView {

    @IBOutlet weak var tenantTextfield: UITextField!
    @IBOutlet weak var userIdTextfiled: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var serverUrlTextfield: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    @IBAction func LoginButtonClicked(_ sender: UIButton) {
      
      

        let loginParam = [
            "userId": tenantTextfield.text! +  "." + userIdTextfiled.text!,
            "password": passwordTextfield.text!
        ]

        Storage.shareStorage.login(param: loginParam, serverUrl: serverUrlTextfield.text! + urlSuffix) { (isSuccess) in
            if isSuccess {
                SVProgressHUD.showSuccess(withStatus: "Login Successfully!")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.endEditing(true)
                    (self.superview?.next as!LoginVC).navigationController?.pushViewController(MyExpenseReportVC(), animated: true)
                }
            } else {
                SVProgressHUD.showError(withStatus: "Login failed !")
            }
        }
    }
    
    class func XibLoginView() -> LoginView {
        
        return Bundle.main.loadNibNamed("LoginView", owner: self, options: nil)?.last as! LoginView
        
    }
    override func awakeFromNib() {
        
        LoginButton.setBackgroundImage(UIImage(named:"login_sel"), for: .normal)
//        LoginButton.setBackgroundImage(UIImage(named:"login_sel"), for: .selected)
        
    }
    
    

}
