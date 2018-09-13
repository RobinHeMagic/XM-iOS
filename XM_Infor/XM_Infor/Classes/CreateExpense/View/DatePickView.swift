//
//  DatePickView.swift
//  XM_Infor
//
//  Created by Robin He on 11/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

let PICKERHEIGHT: CGFloat = 216
let BGHEIGHT: CGFloat = 256
let BGWIDTH = UIScreen.main.bounds.width

let KEY_WINDOW_HEIGHT = UIApplication.shared.keyWindow?.frame.size.height

typealias ResultClosure = (String, String, String,String) -> Void

class DatePickView: XMPIckView {

    var selectRow: Int = 0
    
    var yearStr: String?
    var monthStr: String?
    var dayStr: String?
    
    var numStr:String?
    
    var myClosure: ResultClosure?
    
    var dateArray = [String]()
    
    
    fileprivate lazy var yearArray: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    fileprivate lazy var monthArray: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    fileprivate lazy var dayArray: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    fileprivate lazy var dataSource: NSArray = {
        let array: NSArray = NSArray()
        return array
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.loadDatas()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func loadDatas() -> Void {
        let path = Bundle.main.path(forResource: "date", ofType: "plist")
        self.dataSource = NSArray.init(contentsOfFile: path!)!
        
        let tempArray = NSMutableArray()
        for dic in self.dataSource {
            
            for (year,_) in dic as! NSDictionary {
                tempArray.add(year)
            }
            
        }
        
        self.yearArray = tempArray.copy() as! NSArray
        self.monthArray = self.getmonthNameFromyear(row: 0)
        self.dayArray = self.getdayNameFrommonth(row: 0)
       
        self.yearStr = ""
        self.monthStr = ""
        self.dayStr = ""


       dateArray = NSString(string:nowDateString()).components(separatedBy: " ")
    
        let DAYArray = ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
        
        let  index0 = DAYArray.index(of: dateArray[0] as String) ?? 0
        let index = dateArray[1].index(dateArray[1].endIndex, offsetBy: -1)
        let suffix = dateArray[1].substring(to: index)
       
        let index1 = monthArray.index(of: suffix)
        let  index2 = yearArray.index(of: dateArray[2] as String) 
        
        self.pickerView.selectRow(index2,inComponent:0,animated:true)
        self.pickerView.selectRow(index1,inComponent:1,animated:true)
        self.pickerView.selectRow(index0,inComponent:2,animated:true)

    }
    
    //
    func getdayNameFrommonth(row: NSInteger) -> NSArray {
        let tempDic = self.dataSource[self.selectRow] as! NSDictionary
        let tepDic = tempDic.object(forKey: self.yearArray[self.selectRow]) as! NSDictionary
        
        let array = tepDic.allValues[row] as! NSArray
        
        return array
    }
    
 
    func getmonthNameFromyear(row: NSInteger) -> NSArray {
        
        let monthArray:NSArray = ["Janurary","February","March","April","May","June","July","August","September","October", "November","December"]
        
        return monthArray
    }
    
    
    override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.yearArray.count
        case 1:
            return self.monthArray.count
        case 2:
            return self.dayArray.count
        default:
            return 0
        }
    }
    override func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width / 3, height: 30))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
//        label.backgroundColor = UIColor.cyan
        switch component {
        case 0:
            label.text = self.yearArray[row] as? String
        case 1:
            label.text = self.monthArray[row] as? String
        case 2:
            label.text = self.dayArray[row] as? String
        default:
            label.text = nil
        }
        return label
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: //选择年
            self.selectRow = row
            self.monthArray = self.getmonthNameFromyear(row: row)
            self.dayArray = self.getdayNameFrommonth(row: 0)
            self.pickerView.reloadComponent(1)
            self.pickerView.selectRow(0, inComponent: 1, animated: true)
            self.pickerView.reloadComponent(2)
            self.pickerView.selectRow(0, inComponent: 2, animated: true)
            
            self.yearStr = self.yearArray[row] as? String
            self.monthStr = self.monthArray[0] as? String
            
            numStr = "1"
        
            self.dayStr = self.dayArray[0] as? String
            
        case 1: //选择月份
            self.dayArray = self.getdayNameFrommonth(row: row)
            self.pickerView.reloadComponent(2)
            self.pickerView.selectRow(0, inComponent: 2, animated: true)
            
            self.monthStr = self.monthArray[row] as? String
            numStr = "0\(row+1)"
            self.dayStr = self.dayArray[0] as? String
            
        default:
            self.dayStr = self.dayArray[row] as? String
            break//选择天
        }
        
        if monthStr == "" {
            let dateArray = NSString(string:nowDateString()).components(separatedBy: " ")
            
            let index = dateArray[1].index(dateArray[1].endIndex, offsetBy: -1)
            
           numStr =  nowNumDateString()
            
            self.monthStr = dateArray[1].substring(to: index)
            self.yearStr =  dateArray[2]
        }
        
        if yearStr == "" {
        
            let dateArray = NSString(string:nowDateString()).components(separatedBy: " ")
        
            self.yearStr =  dateArray[2]
                    
        }
    }
    
    override func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
  
    override func sureBtnClick()  {
       
        super.sureBtnClick()
        
        if yearStr == "" && monthStr == "" && dayStr == "" {
            
            let subMonthStr = dateArray[1].substring(to: dateArray[1].index(dateArray[1].startIndex, offsetBy: dateArray[1].characters.count-1))
            self.myClosure!(dateArray[2], subMonthStr, dateArray[0],nowNumDateString())
           
            return
        }
        
        if self.myClosure != nil {
            
            print(numStr ?? "==")
            
            self.myClosure!(self.yearStr!, self.monthStr!, self.dayStr!,numStr!)
        }
        
        
    }

}
