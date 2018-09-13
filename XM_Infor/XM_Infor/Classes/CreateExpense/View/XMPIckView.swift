//
//  XMPIckView.swift
//  XM_Infor
//
//  Created by Robin He on 10/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

class XMPIckView: UIView,UIPickerViewDelegate, UIPickerViewDataSource {

     lazy var bgView: UIView = {
        let view = UIView()
        view.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.height, width: BGWIDTH, height: BGHEIGHT)
        view.backgroundColor = UIColor.white
        return view
    }()
     lazy var pickerView :UIPickerView = {
        let pv = UIPickerView()
        pv.frame = CGRect.init(x: 0, y: BGHEIGHT - PICKERHEIGHT, width: BGWIDTH, height: PICKERHEIGHT)
        pv.delegate = self
        pv.dataSource = self
        return pv
    }()
     lazy var toolBarView: UIView = {
        let tv = UIView()
        tv.frame = CGRect.init(x: 0, y: 0, width: BGWIDTH, height: BGHEIGHT - PICKERHEIGHT)
        tv.backgroundColor = UIColor.groupTableViewBackground
        return tv
    }()
    
     lazy var cancleBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: 10, y: 5, width: 50, height: BGHEIGHT - PICKERHEIGHT - 10)
        btn.setTitle("Cancel", for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.cornerRadius = 5
        btn.backgroundColor = UIColor.orange
        btn.addTarget(self, action: #selector(cancleBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    
     lazy var sureBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect.init(x: BGWIDTH - 60, y: 5, width: 50, height: BGHEIGHT - PICKERHEIGHT - 10)
        btn.setTitle("Done", for: UIControlState.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.layer.cornerRadius = 5
        btn.backgroundColor = UIColor.orange
        btn.addTarget(self, action: #selector(sureBtnClick), for: UIControlEvents.touchUpInside)
        
        return btn
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    func initSubViews() -> Void {
        self.addSubview(self.bgView)
        
        self.bgView.addSubview(self.pickerView)
        self.bgView.addSubview(self.toolBarView)
        self.toolBarView.addSubview(self.cancleBtn)
        self.toolBarView.addSubview(self.sureBtn)
        
        self.showPickerView()
    }
    
    //showPickerView
    func showPickerView() -> Void {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.bgView.frame = CGRect.init(x: 0, y: KEY_WINDOW_HEIGHT! - BGHEIGHT + 64, width: BGWIDTH, height: BGHEIGHT)
        }
    }
    
    //hidePickerView
    func hidePickerView() -> Void {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.frame = CGRect.init(x: 0, y: KEY_WINDOW_HEIGHT!, width: BGWIDTH, height: BGHEIGHT)
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    //cancel buttton
    func cancleBtnClick()  {
        self.hidePickerView()
    }
    
    // confirm button
    func sureBtnClick()  {
        self.hidePickerView()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hidePickerView()
    }
    
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return 0
        
    }
    
    
    
     func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        return UILabel()
    }
    
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    
     func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 0.0
    }
    
     func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }


}
