//
//  AddExpenseTypeFirstView.swift
//  XM_Infor
//
//  Created by 何兵兵 on 2017/7/8.
//  Copyright © 2017年 Robin He. All rights reserved.
//

import UIKit

class AddExpenseTypeFirstView: UIView {

    var searchV:UITextField?
    var LocationCallback:((Array<Any>)->())?
    var type = ""
    
    var option = 0
    
    var isCost = false
    
    init(frame: CGRect, bySearch:Bool, isCostCenter:Bool) {
        super.init(frame: frame)
        backgroundColor = UIColor.colorWithHexString("2f5e7b")
        searchV = UITextField(frame: CGRect(x: 20, y: 45, width: self.bounds.width - 40, height: 55))
        searchV?.placeholder = "Search"
        searchV?.becomeFirstResponder()
        searchV?.backgroundColor = UIColor.white
        NotificationCenter.default.addObserver(self, selector: #selector(textChange(notification:)),
            name: .UITextFieldTextDidChange, object: nil)
        
        let usView = UIView.init(frame: CGRect(x:0, y:0, width:40, height:40))
        
        let userImageV = UIImageView()
        userImageV.image = UIImage(named: "magnifying21")
        userImageV.frame = CGRect(x:10, y:5, width:25, height:30)
        userImageV.contentMode = .scaleAspectFit
        usView.addSubview(userImageV)
        searchV?.leftView = usView
        
        searchV?.leftViewMode = .always
        searchV?.layer.borderWidth = 0.5
        searchV?.layer.borderColor = UIColor.gray.cgColor
        searchV?.layer.cornerRadius = 28
        searchV?.layer.masksToBounds = true
        if bySearch == true {
            addSubview(searchV!)
        }
        isCost = isCostCenter
    }
    
    deinit {
        print("AddExpenseTypeFirstView 被销毁了")
        NotificationCenter.default.removeObserver(self)
    }
    func textChange(notification:NSNotification) {
        if isCost == false {
            Storage.shareStorage.corporDataBySearch(type: type, keyWord: (searchV?.text)!, finished: {[weak self]  (LocationItems)  in
                print(LocationItems)
                self?.LocationCallback!(LocationItems)
            })
        } else {
            switch option {
            case 1:
                Storage.shareStorage.chargeCode(project: false, costCenter: true, query: (searchV?.text)!, finished: {[weak self] (LocationItems) in
                    print(LocationItems)
                    self?.LocationCallback!(LocationItems)
                })
            case 2:
                Storage.shareStorage.chargeCode(project: true, costCenter: false, query: (searchV?.text)!, finished: {[weak self] (LocationItems) in
                    print(LocationItems)
                    self?.LocationCallback!(LocationItems)
                })
            case 3:
                Storage.shareStorage.chargeCode(project: true, costCenter: true, query: (searchV?.text)!, finished: {[weak self] (LocationItems) in
                    print(LocationItems)
                    self?.LocationCallback!(LocationItems)
                })
            default:
                print("dsdsa")
            }
        
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
