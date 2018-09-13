//
//  CurrencyPickView.swift
//  XM_Infor
//
//  Created by Robin He on 25/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

typealias currencyClosure = (String) -> Void

class CurrencyPickView: XMPIckView{

     var curClosure: currencyClosure?
    
    var currencyTypeArray = [String]()
    
     var currencyString = ""
    

    
    fileprivate lazy var currencyArray: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let index = currencyTypeArray.index(of: "US Dollar")
            else{
                print("there isn't US Dollar")
                return
        }
        self.pickerView.selectRow(index,inComponent:0,animated:true)
    }
    
//    //showPickerView
//    override func showPickerView() -> Void {
//        UIView.animate(withDuration: 0.3) {
//            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//            self.bgView.frame = CGRect.init(x: 0, y: KEY_WINDOW_HEIGHT! - BGHEIGHT, width: BGWIDTH, height: BGHEIGHT)
//        }
//    }
//
//    //hidePickerView
//    override func hidePickerView() -> Void {
//
//        UIView.animate(withDuration: 0.3, animations: {
//            self.bgView.frame = CGRect.init(x: 0, y: KEY_WINDOW_HEIGHT!, width: BGWIDTH, height: BGHEIGHT)
//            self.alpha = 0
//        }) { (finished) in
//            self.removeFromSuperview()
//        }
//    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       
            return currencyTypeArray.count
        
    }
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width / 3, height: 30))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        label.text = currencyTypeArray[row]
        return label
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
            currencyString = currencyTypeArray[row]
    }

    override func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    //确定按钮
    override func sureBtnClick()  {

        if self.curClosure != nil {
            
            if currencyString == "" {
                currencyString = "$ US Dollar"
            }
            self.curClosure!(currencyString)
        }
    }


}
