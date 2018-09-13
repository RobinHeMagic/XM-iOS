//
//  ViewController+Extension.swift
//  XM_Infor
//
//  Created by Jeremy Wang on 14/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ViewController_Extension: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension UIViewController {
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    func popToRootViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func popToRootExpenseViewController(){
        /// get name space
        let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        guard let VCs = self.navigationController?.childViewControllers else {
            return
        }
        for vc in  VCs{
            if NSStringFromClass(vc.classForCoder) == namespace + "." + "MyExpenseReportVC" {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
}
