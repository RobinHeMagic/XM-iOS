//
//  AddAllocationTitleView.swift
//  XM_Infor
//
//  Created by Robin He on 24/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
@objc
protocol AddAllocationTitleViewDelegate:NSObjectProtocol {
    
    @objc optional func AddAllocationTitleViewWithButon(btn:UIButton)
    
}
class AddAllocationTitleView: UIView {

    weak var delegate:AddAllocationTitleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let btn1 = UIButton()
        btn1.setTitle("CostCenter", for: [])
        btn1.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn1.setTitleColor(UIColor.white, for: [])
        btn1.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        
        let linelab = UILabel()
        linelab.backgroundColor = UIColor.white

        linelab.alpha = 0.7
        let btn2 = UIButton()
        btn2.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn2.setTitle("ProjectNumber", for: [])
        btn2.setTitleColor(UIColor.darkGray, for: [])
        btn2.isEnabled = false
        btn2.addTarget(self, action: #selector(btnClick), for: .touchUpInside)
        
        self.addSubview(btn1)
        self.addSubview(linelab)
        self.addSubview(btn2)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for (i,v) in subviews.enumerated() {
            v.frame = CGRect(x: 5, y: 10 + i*30, width: 90, height: 50)
            if i == 1 {
                v.frame = CGRect(x: 5, y: 65, width: 90, height: 0.5)
            }
        }
    }
    
    func btnClick(btn:UIButton) {
        
        delegate?.AddAllocationTitleViewWithButon!(btn: btn)
        
        
    }

}








