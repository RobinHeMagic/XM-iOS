//
//  NSObject+Extension.swift
//  XM_Infor
//
//  Created by Robin He on 11/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import Foundation
import RealmSwift
extension NSObject{

    func postNotificationName(name:String,andUserInfo userInfo:[String:Any]){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: nil, userInfo: userInfo)
        
    }
    
    func addNotificationObserver(name:String){
      
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name:NSNotification.Name(rawValue: name), object: nil)
    }

    func handleNotification(notification:NSNotification) {
        
        
    }

    func removeNotificationObserver() {
        
         NotificationCenter.default.removeObserver(self)
    }



}

extension NSObject
{
    class func printIvars() -> [String]{
        // Using run-time access to the inside of the class member variables
        var outCount: UInt32 = 0
        // ivars Is actually an array
        guard  let ivars = class_copyIvarList(self, &outCount) else {
            return []
        }
        // Access to the inside of the each element
        var Ivars = [String]()
        for i in 0..<outCount
        {
            // Get the name of the member variables, cName c strings, the first element address
            let ivar = ivars[Int(i)]
            let cName = ivar_getName(ivar)
            let name =  String(cString: cName!)
            print("name: \(name)")
            Ivars.append(name)
        }
         // Method of copy, create, needs to be released
        free(ivars)
        return Ivars
    }
}

