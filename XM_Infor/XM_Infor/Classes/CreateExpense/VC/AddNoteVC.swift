//
//  AddNoteVC.swift
//  XM_Infor
//
//  Created by 何兵兵 on 2017/7/8.
//  Copyright © 2017年 Robin He. All rights reserved.
//

import UIKit

class AddNoteVC: UIViewController {
    
    var WNView:WriteNoteView?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initView()
    }
}

extension AddNoteVC {

    func initView() {
        
        WNView = WriteNoteView.loadXibWriteNoteView()
        guard let WNView = WNView else {
            return
        }
        WNView.frame = CGRect(x:0,y:0,width:view.frame.size.width,height:450)
        view.addSubview(WNView)
        WNView.callBack = {[weak self](text) in
            self?.WNView?.myTextView.resignFirstResponder()
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
