//
//  ExpenseAllButtonView.swift
//  XM_Infor
//
//  Created by Robin He on 30/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class ExpenseAllButtonView: UIView {
    var btnClosure:((Int)->())?
    let buttonInfo = [["imageName":"banknotes","title":"All Expenses"],["imageName":"icon_wallet","title":"Out of Pocket"],["imageName":"credit59","title":"Corporate Card"]]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    func setupUI() {
        for i in 0..<3 {
            let dict = buttonInfo[i]
            guard let imageName = dict["imageName"],let title = dict["title"] else {
                continue
            }
            let eb =  ExpenseButton.XMExpenseButton(imageName: imageName, title: title)
            eb.addTarget(self, action: #selector(btnAct), for: .touchUpInside)
            eb.tag = i + 1
            if i == 0 {
                eb.BGimageView.isHidden = false
            }
            addSubview(eb)
        }
        let btnSize = CGSize(width: 90, height: 90)
        let margin = (SCREEN_WIDTH - 10 - 3 * btnSize.width) / 4
        for (i,btn) in subviews.enumerated() {
            let col = i % 3
            btn.x = CGFloat(col + 1) * margin + CGFloat(col) * btnSize.width
            btn.y = 10
            btn.width = 90
            btn.height = 90
        }
    }
    
    func btnAct(btn:ExpenseButton){
        
        btn.BGimageView.isHidden = false
        for (i,subBtn) in subviews.enumerated() {
            if btn.tag == i + 1 {
                btnClosure!(btn.tag)
                continue
            }
            (subBtn as!ExpenseButton).BGimageView.isHidden = true
        }
    }
    
    
    
    
}
