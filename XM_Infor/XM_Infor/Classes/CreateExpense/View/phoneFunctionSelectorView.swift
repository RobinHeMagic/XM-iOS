//
//  phoneFunctionSelectorView.swift
//  XM_Infor
//
//  Created by Robin He on 31/08/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import Photos
typealias PhoneResClosure = ([UIImage],[PHAsset]) -> Void
typealias CameraResClosure = (Data) -> Void
class phoneFunctionSelectorView: UIView,UITableViewDelegate,UITableViewDataSource {

    var phoneTabV:UITableView?
    var cancelBtn:CancelButton?
    var myClosure: PhoneResClosure?
    var cameraClosure:CameraResClosure?
    
    let cellDict = [["imageName":"credit36","title":"Capture Receipt"],["imageName":"credit16","title":"Attach from Camera Roll"],["imageName":"cards5","title":"Attach from XM Receipt"]]
    var phoneItems = [UIImage]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        self.alpha = 0.3
        phoneTabV = UITableView()
        phoneTabV?.delegate = self
        phoneTabV?.dataSource = self
        phoneTabV?.frame = CGRect(x: getLength(leng: 10), y: SCREEN_HEIGHT, width: getLength(leng: 355), height: 180)
        phoneTabV?.isScrollEnabled = false
        phoneTabV?.layer.cornerRadius = 10
        phoneTabV?.register(UINib.init(nibName: "FloatingBallTabViewCell", bundle: nil), forCellReuseIdentifier: "FloatingBallTabViewCell")
        
        cancelBtn = CancelButton.XMCancelButton()
        cancelBtn?.frame = CGRect(x: getLength(leng: 10), y: SCREEN_HEIGHT + 185, width: getLength(leng: 355), height: 60)
        cancelBtn?.layer.cornerRadius = 10
        cancelBtn?.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
    
    }
    
    func cancelBtnClick() {
        
        print("cancelBtnClick")
        UIView.animate(withDuration: 0.3) {
            self.phoneTabV?.y = SCREEN_HEIGHT
            self.cancelBtn?.y = SCREEN_HEIGHT + 185
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.phoneTabV?.removeFromSuperview()
            self.cancelBtn?.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelBtnClick()
    }
       required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension phoneFunctionSelectorView {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FloatingBallTabViewCell") as! FloatingBallTabViewCell
        
        cell.selectionStyle = .none
        cell.titleImageView.image =  UIImage(named:cellDict[indexPath.row]["imageName"]!)
        cell.titleLabel.text = cellDict[indexPath.row]["title"]
        
        return  cell
    
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        cancelBtnClick()
        
        if indexPath.row == 0 {
            
            if Platform.isSimulator {
                // Do one thing
                print("Simulator can't capture !")
            } else {
                // Do the other
                DispatchQueue.main.async {
                    let cameraVC = HsuCameraViewController()
                    cameraVC.callbackPicutureData = { imgData in

                        self.cameraClosure!(imgData!)
                    }
                    UIApplication.shared.keyWindow?.currentViewController()?.present(cameraVC, animated: true, completion: nil)
                }
            }
          
        } else if indexPath.row == 1 {
            let gridVC = HsuAssetGridViewController()
            let navi = UINavigationController(rootViewController: gridVC)
            gridVC.title = "All photos"
            let nextRespond =  superview?.next! as! UINavigationController
            nextRespond.present(navi, animated: true, completion: nil)
            HandleSelectionPhotosManager.share.getSelectedPhotos(with: 1) { (assets, images) in
                    self.myClosure!(images, assets)
                }
        } else {
        
           
            let vc = AddressBookViewController()
            
            
            
        }
        
    }
}
// 获取当前UIViewController
/** @abstract UIWindow hierarchy category.  */
public extension UIWindow {
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
    public func topMostController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    /** @return Returns the topViewController in stack of topMostController.    */
    public func currentViewController()->UIViewController? {
        
        var currentViewController = topMostController()
        
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        
        return currentViewController
    }
}

extension phoneFunctionSelectorView:UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate {
    
    
    func selectExistPicture() {
        
        getMediaFromSource(sourceType:.photoLibrary)
    }
    
    func shootPicture(){
        
        getMediaFromSource(sourceType:.camera)
        
    }
    
    func getMediaFromSource(sourceType:UIImagePickerControllerSourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let pc = UIImagePickerController()
            //            pc.mediaTypes = ["kUTTypeImage"]
            pc.delegate = self
            pc.allowsEditing = true
            pc.sourceType = sourceType
            (cancelBtn?.superview?.next as!CreatExpenseVC).navigationController?.present(pc, animated: true, completion: nil)
            
        } else {
            
            let alterMsg = "Your device camera can't be captured !"
            
            alertShowErrorMsg(alterMsg: alterMsg)
            
        }
    }
    
    func alertShowErrorMsg(alterMsg:String){
        
        let alertView = UIAlertView(title: alterMsg, message: "", delegate: self, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {
            
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated:true, completion:nil)
    }
    
}

