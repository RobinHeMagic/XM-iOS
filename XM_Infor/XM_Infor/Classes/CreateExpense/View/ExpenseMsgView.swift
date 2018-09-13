//
//  ExpenseMsgView.swift
//  XM_Infor
//
//  Created by Robin He on 04/07/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD
class ExpenseMsgView: UIView {
    
    @IBOutlet weak var PhoneCountLabel: UILabel!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var AddNoteView: UIView!
    @IBOutlet weak var AddNoteLabel: UILabel!
    @IBOutlet weak var DateButton: UIButton!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var CurrencyButton: UIButton!
    @IBOutlet weak var ExpenseAmountLabel: UILabel!
    @IBOutlet weak var AmountTextfield: UITextField!
    @IBOutlet weak var CurrencyLabel: UILabel!
    
    var PhoneImages = [UIImage]()
    var currenctIndex = 0
    var isSelectPhoto = false
    var PhotoScrollView:UIScrollView?
    var imageViewItems = [UIImageView]()
    var currentImageV:UIImageView?
    var photoUrlItems = [String]()
    // write a dict param
    var receiptDict = [String:Any]()
    //As the symbol of store image resources
    var localId:String!
    @IBAction func AddPhooneButton(_ sender: Any) {
        guard (superview?.superview?.next?.isKind(of:UIViewController.self))!,
            superview?.superview?.next != nil
            else {
                return
        }
        self.endEditing(true)
        guard  let nextRespond =  UIApplication.shared.keyWindow?.rootViewController else{
            return
        }
        nextRespond.view.addSubview(phoneView)
        nextRespond.view.addSubview(phoneView.phoneTabV!)
        nextRespond.view.addSubview(phoneView.cancelBtn!)
        /// get photos from albums
        phoneView.myClosure = {[weak self] (_,assets) in
            self?.loadImage(assets: assets)
            self?.resetGetPhotoRoute(asset: assets.last!, isCamera: false, cameraImage: UIImage())
        }
        /// take photos get photos
        phoneView.cameraClosure = { [weak self] imageData in
            let cameraImage = UIImage(data: imageData)!
            self?.phoneImageView.image = cameraImage
            self?.currentImageV = self?.phoneImageView
            self?.PhoneImages = [cameraImage]
            let image = UIImage(data: imageData)!
            PHPhotoLibrary.shared().performChanges({
                let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = result.placeholderForCreatedAsset
                // save localIdentifier
                self?.localId = assetPlaceholder?.localIdentifier
            }) { (isSuccess: Bool, error: Error?) in
                if isSuccess {
                    print("Save Successfully!")
                    //Through the identifier to obtain the corresponding resources
                    let assetResult = PHAsset.fetchAssets(
                        withLocalIdentifiers: [(self?.localId)!], options: nil)
                    self?.resetGetPhotoRoute(asset: assetResult[0], isCamera: true, cameraImage: cameraImage)
                } else{
                    print("save Failed ：", error!.localizedDescription)
                }
            }
            print(imageData)
            print(String(format: "%.2f", CGFloat(CGFloat(imageData.count) / CGFloat(1024 * 1024))),CGFloat(imageData.count))
        }
        UIView.animate(withDuration: 0.35) {
            self.phoneView.phoneTabV?.y = SCREEN_HEIGHT - 320
            self.phoneView.cancelBtn?.y = SCREEN_HEIGHT - 135
        }
    }
    var AmountTextfieldIsEdit = false
    
    lazy var phoneView:phoneFunctionSelectorView = {
        
        let phoneV = phoneFunctionSelectorView()
        phoneV.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        return phoneV
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.insertSublayer(getGradientColorGradientLayer(w: 375, h: 255, view: bgView), at: 0)
        PhoneCountLabel.text = "" // if phone count is null , PhoneCountLabel.text == ""
        let tapGes = UITapGestureRecognizer()
        tapGes.addTarget(self, action: #selector(tapGestureAct))
        phoneImageView.addGestureRecognizer(tapGes)
        setUpNoteView()
        
        DateButton.setTitle(nowDateString(), for: [])
        AmountTextfield.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        NotificationCenter.default.addNotificationObserver(name: NSNotification.Name.UITextFieldTextDidBeginEditing.rawValue)
        NotificationCenter.default.addNotificationObserver(name: NSNotification.Name.UITextFieldTextDidEndEditing.rawValue)
        
        let gesTap =  UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        AddNoteView.addGestureRecognizer(gesTap)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension ExpenseMsgView{
    func loadImage(assets:[PHAsset])  {
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        var size = CGSize(width: 0, height:0)
        if Platform.isSimulator {
            // Do one thing
            size = CGSize(width: SCREEN_WIDTH, height:SCREEN_HEIGHT)
        } else {
            // Do the other
            // size = CGSize(width: 256, height:256)
            size = CGSize(width: SCREEN_WIDTH, height:SCREEN_HEIGHT)
        }
        PHImageManager.default().requestImage(for: assets.last!, targetSize:size, contentMode: .aspectFill, options: options) {[weak self](img, _) in
            //                return img
            self?.currenctIndex = 0 // ----warning: there must be 0 , else there is bug !  ------
            self?.phoneImageView.image = img!
            self?.currentImageV = self?.phoneImageView
            self?.PhoneImages = [img!]
            if [img!].count != 1 {
                self?.PhoneCountLabel.text = "\([img!].count)"
            }
        }
    }
    
    func resetGetPhotoRoute(asset:PHAsset,isCamera:Bool,cameraImage:UIImage) {
        
        let optis = PHContentEditingInputRequestOptions()
        optis.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData)
            -> Bool in
            return true
        }
        asset.requestContentEditingInput(with: optis, completionHandler: {[weak self] (contentEditingInput, info) in
            let subStr = (contentEditingInput!.fullSizeImageURL!.absoluteString as NSString).substring(from: 7)
            self?.photoUrlItems.append(subStr)
            let strArr = subStr.components(separatedBy: "/")
            let a = NSString(string:strArr.last!)
            var b = ""
            if a.components(separatedBy: "HEIC").count > 1{
                b = a.replacingOccurrences(of: "HEIC", with: "jpg")
            } else {
                b = strArr.last!
            }
            self?.receiptDict.updateValue(b, forKey: "name")
            print(UIImageJPEGRepresentation((self?.phoneImageView.image)!,1.0)!)
            guard var imageData = UIImageJPEGRepresentation((self?.phoneImageView.image)!.scaleImage(scaleSize: 1.0),1.0) else{
                return
            }
            print(String(format: "%.2f", CGFloat(CGFloat(imageData.count) / CGFloat(1024 * 1024))),CGFloat(imageData.count))
            var scale:CGFloat = 0
            if isCamera{
                if cameraImage.size.width > cameraImage.size.height{
                    if cameraImage.size.width > 1010{
                        scale = CGFloat(1010) / CGFloat(cameraImage.size.width)
                        imageData = UIImageJPEGRepresentation((self?.phoneImageView.image)!.scaleImage(scaleSize: scale),1.0)!
                        print(String(format: "%.2f%", CGFloat(CGFloat(imageData.count) / CGFloat(1024 * 1024))),CGFloat(imageData.count))
                    }
                } else {
                    if cameraImage.size.height > 1010{
                        scale = CGFloat(1010) / CGFloat(cameraImage.size.height)
                        imageData = UIImageJPEGRepresentation((self?.phoneImageView.image)!.scaleImage(scaleSize: scale),1.0)!
                        print(String(format: "%.2f%", CGFloat(CGFloat(imageData.count) / CGFloat(1024 * 1024))))
                    }
                }
            } else{
                if asset.pixelWidth > asset.pixelHeight{
                    if asset.pixelWidth > 1010{
                        scale = CGFloat(1010) / CGFloat(asset.pixelWidth)
                        imageData = UIImageJPEGRepresentation((self?.phoneImageView.image)!.scaleImage(scaleSize: scale),1.0)!
                        print(String(format: "%.2f%", CGFloat(CGFloat(imageData.count) / CGFloat(1024 * 1024))),CGFloat(imageData.count))
                    }
                } else {
                    if asset.pixelHeight > 1010{
                        scale = CGFloat(1010) / CGFloat(asset.pixelHeight)
                        imageData = UIImageJPEGRepresentation((self?.phoneImageView.image)!.scaleImage(scaleSize: scale),1.0)!
                        print(String(format: "%.2f%", CGFloat(CGFloat(imageData.count) / CGFloat(1024 * 1024))))
                    }
                }
            }
            
            let base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
            self?.receiptDict.updateValue(base64String, forKey: "image")
            UserDefaults.standard.set(self?.receiptDict, forKey: "receiptDict")
//            SVProgressHUD.show(withStatus: "Uploading receipt,please wait for a moment !")
//            XMNetworking.shareInstance.postReceiptItem(receiptDit: (self?.receiptDict)!, finished: { result in
//                if result == true {
//                    SVProgressHUD.showSuccess(withStatus: "post successfully!")
//                }
//            })
        })
    }
    
    func tapGestureAct(){
        
        if PhoneImages.count == 0 {
            return
        }
        guard (superview?.superview?.next?.isKind(of:UIViewController.self))!,
            superview?.superview?.next != nil
            else {
                return
        }
        let  broswerPc = BigImageBrowserPC()
        broswerPc.phoneItems = PhoneImages
        broswerPc.selectCurrentClosure = { [weak self] (image,index,scrollew,isSelect,currentImagV) in
            self?.phoneImageView.image = image
            self?.currenctIndex = index
            self?.isSelectPhoto = isSelect
            self?.currentImageV = currentImagV
        }
        broswerPc.currentImageV = self.currentImageV!
        broswerPc.currenctIndex = self.currenctIndex
        broswerPc.isSelectPhoto = self.isSelectPhoto
        
        UIApplication.shared.keyWindow?.rootViewController?.addChildViewController(broswerPc)
        UIApplication.shared.keyWindow?.addSubview(broswerPc.view)
        broswerPc.presentViewControllerAnimated(curentImgView: self.currentImageV!, animated: true)
        
    }
    
    func tapGesture() {
        
        guard (superview?.superview?.next?.isKind(of:UIViewController.self))!,
            superview?.superview?.next != nil
            else {
                return
        }
        let nextRespond =  superview?.superview?.next! as! CreatExpenseVC
        //        let nav = UINavigationController(rootViewController: AddNoteVC())
        nextRespond.navigationController?.present(AddNoteVC(), animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        AmountTextfield.resignFirstResponder()
    }
    
}
extension ExpenseMsgView{
    func setUpNoteView() {
        AddNoteLabel.textColor = UIColor.colorWithRGB(22, g: 78, b: 112)
        AddNoteView.layer.borderWidth = 0.5
        AddNoteView.layer.borderColor = UIColor.gray.cgColor
        AddNoteView.layer.cornerRadius = 5
        AddNoteView.layer.masksToBounds = true
    }
}
extension ExpenseMsgView {
    override func handleNotification(notification: NSNotification) {
        switch notification.name {
        case NSNotification.Name.UITextFieldTextDidBeginEditing:
            DateButton.isEnabled = false
            CurrencyButton.isEnabled = false
            print("UIKeyboardWillHide")
        case NSNotification.Name.UITextFieldTextDidEndEditing:
            DateButton.isEnabled = true
            CurrencyButton.isEnabled = true
            print("UITextFieldTextDidEndEditing")
        default:
            print("==")
        }
    }
}

