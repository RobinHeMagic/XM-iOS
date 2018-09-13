//
//  Config.swift
//  XM_Infor
//
//  Created by Robin He on 14/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit

let SCREEN_BOUNDS = UIScreen.main.bounds
let SCREEN_SIZE = SCREEN_BOUNDS.size

let SCREEN_WIDTH = SCREEN_BOUNDS.width
let SCREEN_HEIGHT = SCREEN_BOUNDS.height
let COLOR_BG = UIColor.colorWithRGB(22, g: 78, b: 112)

let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!

var loginParam = [String:Any]() // user required loginParam ， use in many places
var serviceUrl = "" // user required serviceUrl ， use in many places
let urlSuffix = "/xm-api/v1/application/"

var networkStatus = false


let months = ["Jan", "Feb", "Mar", "Apr", "May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"]


func timeBecomeString(timeStringItems:[String]) -> [String] {
    
    var timeResults = [String]()
//    let timeItems = ["2017/09/12","2016/12/12","2017/09/14","2017/09/11","2017/09/13"]
    var timeArray = [Int]()
    for time in timeStringItems {
        let formatter:DateFormatter = DateFormatter()
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        formatter.dateFormat = "yyyy/MM/dd"
        let date:NSDate = formatter.date(from: "\(time)")! as NSDate
        let timeInterval:TimeInterval = date.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        print(timeStamp)
        timeArray.append(timeStamp)
    }
    timeArray.sort(by: {(num1, num2) in
        return num1 > num2
    })
    for timeStamp in timeArray {
        let timeInterval:TimeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy/MM/dd"
        print("\(dformatter.string(from: date))")
        
        timeResults.append(dformatter.string(from: date))
    }
    
    return timeResults
    
}

func nowDateString() -> String {
    
    //get current time
    let now = Date()
    // create a dete formater
    let dformatter = DateFormatter()
    dformatter.dateFormat = "dd MM, yyyy"
    return  String().dateChange(dformatter: dformatter,nowDate: now)
}

func nowNormalDateString() -> String {
    
    //get current time
    let now = Date()
    // create a dete formater
    let dformatter = DateFormatter()
    
    dformatter.dateFormat = "yyyy/MM/dd"
  
    return dformatter.string(from: now)
}

func nowNumDateString() -> String{

    //get current time
    let now = Date()
    // create a dete formater
    let dformatter = DateFormatter()
    dformatter.dateFormat = "dd MM, yyyy"
    
    let  dateStr  = (dformatter.string(from: now) as NSString).substring(with: NSMakeRange(3, 2))

    return dateStr
}

func getLength(leng:CGFloat) -> CGFloat{
  return  XMSize().getLengthWithSizeType(sizeType: XMSizeType.SizeType4_7, andLength: leng)
}

func getCurrentTimeInterval() -> Int{
    //get current time
    let now = NSDate()
    //  create a dete formater
    let dformatter = DateFormatter()
    dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss Z"
 
    let timeInterval:TimeInterval = now.timeIntervalSince1970
    let timeStamp = Int(timeInterval)
    return timeStamp
}


func nowDateStringForEnglish() -> String{
    
    //get current time
    let now = Date()
    // create a dete formater
    let dateFormatterForMonth = DateFormatter()
    dateFormatterForMonth.dateFormat = "MM"
    
    let dateFormotterWithoutMonth = DateFormatter()
    dateFormotterWithoutMonth.dateFormat = "d, yyyy"
    
    
//    let  monthStr  = (dateFormatterForMonth.string(from: now) as NSString).substring(with: NSMakeRange(0, 2))
    let monthNum = Int(dateFormatterForMonth.string(from: now))
    
    
    
    let dateStr = months[monthNum! - 1] + " " + dateFormotterWithoutMonth.string(from: now)
    
    
    return dateStr
}

func dateStringToEnglish(date: String) -> String {
    
    let dateNumbers = date.components(separatedBy: "/")
    
    return months[Int(dateNumbers[1])! - 1] + " " + dateNumbers[2] + ", " + dateNumbers[0]
}

func getGradientColorGradientLayer(w: Int, h: Int, view: UIView) -> CAGradientLayer {
    let w = w;
    let h = h;
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [UIColor.colorWithHexString("2f5e7b").cgColor, UIColor.colorWithHexString("7159a7").cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.75, y: 0.25)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0.75)
    gradientLayer.frame = CGRect.init(x: 0, y: 0, width: w, height: h)
    return gradientLayer
}
