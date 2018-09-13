//
//  TimePickView.swift
//  XM_Infor
//
//  Created by Robin He on 20/09/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
typealias timeClosure = (String) -> Void

class TimePickView: XMPIckView {

    var tiClosure: timeClosure?
    
    var timeTypeArray = [String]()
    
    var hourString = ""
    var minString = ""
    
    let hourArray = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]
    
    let minArray = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
    let secondArray = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"]

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //showPickerView
    override func showPickerView() -> Void {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.bgView.frame = CGRect.init(x: 0, y: KEY_WINDOW_HEIGHT! - BGHEIGHT, width: SCREEN_WIDTH, height: BGHEIGHT)
        }
    }
    
    //hidePickerView
    override func hidePickerView() -> Void {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.frame = CGRect.init(x: 0, y: KEY_WINDOW_HEIGHT!, width: SCREEN_WIDTH, height: BGHEIGHT)
            self.alpha = 0
        }) { (finished) in
            self.removeFromSuperview()
        }
    }

    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hourArray.count
        case 1:
            return minArray.count

        default:
            return 0
        }
    }
    
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH / 2, height: 30))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        switch component {
        case 0:
            label.text = self.hourArray[row]
        case 1:
            label.text = self.minArray[row]

        default:
            label.text = nil
        }
        return label
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            print("0")
            
            hourString = hourArray[row]
            
        case 1:
            
            print("1")
            
            minString = minArray[row]
        case 2:
            
            print("1")
            
        default:
            
            print("3")
            break//选择天
        }

    }
    
    override func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    override func sureBtnClick()  {
        
        super.sureBtnClick()

        let timeStr = hourString + ":" + minString
        
        if hourString == "" && minString == "" {
            tiClosure!("")
        }
        if (tiClosure != nil) {
          
            tiClosure!(timeStr)
            
        }
        
        
    }

}
