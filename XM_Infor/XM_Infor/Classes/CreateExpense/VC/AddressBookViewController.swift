//
//  AddressBookViewController.swift
//  XM_Infor
//
//  Created by Robin He on 08/11/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI

class AddressBookViewController: UIViewController{
        //address Book对象，用来获取电话簿句柄
        var addressBook:ABAddressBook?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //定义一个错误标记对象，判断是否成功
            var error:Unmanaged<CFError>?
            addressBook = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
            
            //发出授权信息
            let sysAddressBookStatus = ABAddressBookGetAuthorizationStatus()
            if (sysAddressBookStatus == ABAuthorizationStatus.notDetermined) {
                print("requesting access...")
                var errorRef:Unmanaged<CFError>? = nil
                //addressBook = extractABAddressBookRef(ABAddressBookCreateWithOptions(nil, &errorRef))
                ABAddressBookRequestAccessWithCompletion(addressBook, { success, error in
                    if success {
                        //获取并遍历所有联系人记录
                        self.readRecords();
                    }
                    else {
                        print("error")
                    }
                })
            }
            else if (sysAddressBookStatus == ABAuthorizationStatus.denied ||
                sysAddressBookStatus == ABAuthorizationStatus.restricted) {
                print("access denied")
            }
            else if (sysAddressBookStatus == ABAuthorizationStatus.authorized) {
                print("access granted")
                //获取并遍历所有联系人记录
                self.readRecords();
            }
    
    }
    
    
    

        //获取并遍历所有联系人记录
        func readRecords(){
            var sysContacts = ABAddressBookCopyArrayOfAllPeople(addressBook)
                .takeRetainedValue() as [ABRecord]
            
            for contact in sysContacts {
                //获取姓
                var lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty)?
                    .takeRetainedValue() as! String? ?? ""
                print("姓：\(lastName)")
                
                //获取名
                var firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty)?
                    .takeRetainedValue() as! String? ?? ""
                print("名：\(firstName)")
                
                //昵称
                var nikeName = ABRecordCopyValue(contact, kABPersonNicknameProperty)?
                    .takeRetainedValue() as! String? ?? ""
                print("昵称：\(nikeName)")
                
                //公司（组织）
                var organization = ABRecordCopyValue(contact, kABPersonOrganizationProperty)?
                    .takeRetainedValue() as! String? ?? ""
                print("公司（组织）：\(organization)")
                
                //职位
                var jobTitle = ABRecordCopyValue(contact, kABPersonJobTitleProperty)?
                    .takeRetainedValue() as! String? ?? ""
                print("职位：\(jobTitle)")
                
                //部门
                var department = ABRecordCopyValue(contact, kABPersonDepartmentProperty)?
                    .takeRetainedValue() as! String? ?? ""
                print("部门：\(department)")
                
                //备注
                var note = ABRecordCopyValue(contact, kABPersonNoteProperty)?
                    .takeRetainedValue() as! String? ?? ""
                print("备注：\(note)")
                
                //获取电话
                var phoneValues:ABMutableMultiValue? =
                    ABRecordCopyValue(contact, kABPersonPhoneProperty).takeRetainedValue()
                if phoneValues != nil {
                    print("电话：")
                    for i in 0 ..< ABMultiValueGetCount(phoneValues){
                        
                        // 获得标签名
                        var phoneLabel = ABMultiValueCopyLabelAtIndex(phoneValues, i).takeRetainedValue()
                            as CFString;
                        // 转为本地标签名（能看得懂的标签名，比如work、home）
                        var localizedPhoneLabel = ABAddressBookCopyLocalizedLabel(phoneLabel)
                            .takeRetainedValue() as! String
                        
                        guard var value = ABMultiValueCopyValueAtIndex(phoneValues, i) else{
                            return
                        }
                        var phone = value.takeRetainedValue() as! String
                        print("  \(localizedPhoneLabel):\(phone)")
                    }
                }
                
                //获取Email
                var emailValues:ABMutableMultiValue? =
                    ABRecordCopyValue(contact, kABPersonEmailProperty).takeRetainedValue()
                if emailValues != nil {
                    print("Email：")
                    for i in 0 ..< ABMultiValueGetCount(emailValues){
                        
                        // 获得标签名
                        var label = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue()
                            as CFString;
                        var localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                            .takeRetainedValue() as! String
                        
                        guard  var value = ABMultiValueCopyValueAtIndex(emailValues, i) else{
                            return
                        }
                        var email = value.takeRetainedValue() as! String
                        print("  \(localizedLabel):\(email)")
                    }
                }
                
                //获取地址
                var addressValues:ABMutableMultiValue? =
                    ABRecordCopyValue(contact, kABPersonAddressProperty).takeRetainedValue()
                if addressValues != nil {
                    print("地址：")
                    for i in 0 ..< ABMultiValueGetCount(addressValues){
                        
                        // 获得标签名
                        var label = ABMultiValueCopyLabelAtIndex(addressValues, i).takeRetainedValue()
                            as CFString;
                        var localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                            .takeRetainedValue() as! String
                        
                        guard var value = ABMultiValueCopyValueAtIndex(addressValues, i) else{
                            return
                        }
                        var addrNSDict:NSMutableDictionary = value.takeRetainedValue()
                            as! NSMutableDictionary
//                        var country:String = addrNSDict.valueForKey(kABPersonAddressCountryKey as String)
                        var country:String = addrNSDict.value(forKey: kABPersonAddressCountryKey as String)
                            as? String ?? ""
                        var state:String = addrNSDict.value(forKey:kABPersonAddressStateKey as String)
                            as? String ?? ""
                        var city:String = addrNSDict.value(forKey:kABPersonAddressCityKey as String)
                            as? String ?? ""
                        var street:String = addrNSDict.value(forKey:kABPersonAddressStreetKey as String)
                            as? String ?? ""
                        var contryCode:String = addrNSDict
                            .value(forKey:kABPersonAddressCountryCodeKey as String) as? String ?? ""
                        print("  \(localizedLabel): Contry:\(country) State:\(state) ")
                        print("City:\(city) Street:\(street) ContryCode:\(contryCode) ")
                    }
                }
                
                //获取纪念日
                var dateValues:ABMutableMultiValue? =
                    ABRecordCopyValue(contact, kABPersonDateProperty).takeRetainedValue()
                if dateValues != nil {
                    print("纪念日：")
                    for i in 0 ..< ABMultiValueGetCount(dateValues){
                        
                        // 获得标签名
                        var label = ABMultiValueCopyLabelAtIndex(emailValues, i).takeRetainedValue()
                            as CFString;
                        var localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                            .takeRetainedValue() as! String
                        
                        guard  var value = ABMultiValueCopyValueAtIndex(dateValues, i) else{
                            return
                        }
                        var date = (value.takeRetainedValue() as? NSDate)?.description ?? ""
                        print("  \(localizedLabel):\(date)")
                    }
                }
                
                //获取即时通讯(IM)
                var imValues:ABMutableMultiValue? =
                    ABRecordCopyValue(contact, kABPersonInstantMessageProperty).takeRetainedValue()
                if imValues != nil {
                    print("即时通讯(IM)：")
                    for i in 0 ..< ABMultiValueGetCount(imValues){
                        
                        // 获得标签名
                        var label = ABMultiValueCopyLabelAtIndex(imValues, i).takeRetainedValue()
                            as CFString;
                        var localizedLabel = ABAddressBookCopyLocalizedLabel(label)
                            .takeRetainedValue() as! String
                        
                        guard  var value = ABMultiValueCopyValueAtIndex(imValues, i) else{
                            return
                        }
                        var imNSDict:NSMutableDictionary = value.takeRetainedValue()
                            as! NSMutableDictionary
                        var serves:String = imNSDict
                            .value(forKey:kABPersonInstantMessageServiceKey as String) as? String ?? ""
                        var userName:String = imNSDict
                            .value(forKey:kABPersonInstantMessageUsernameKey as String) as? String ?? ""
                        print("  \(localizedLabel): Serves:\(serves) UserName:\(userName)")
                    }
                }
            }
        }
        
    
}
