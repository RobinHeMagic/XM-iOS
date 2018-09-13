//
//  XMBaseViewController.swift
//  XM_Infor
//
//  Created by Robin He on 03/11/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class XMBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      // prevent tableview to slip up
        let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 0)
        view.addSubview(v)
        
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
