//
//  HsuAssetGridViewController.swift
//  XM_Infor
//
//  Created by Robin He on 18/10/2017.
//  Copyright © 2017 Robin He. All rights reserved.
//

/// Custom camera

import UIKit
import AVFoundation

class HsuCameraViewController: UIViewController {
    
    // MARK: - 👉Properties
    // Access to hardware devices, general is the front and rear cameras and microphones
    private var device: AVCaptureDevice?
    // Input devices, using the device initialization
    private var input: AVCaptureDeviceInput?
    // The output image
    private var imageOutput: AVCapturePhotoOutput?
    // InputBridges, outputBridges, and start the equipment
    private var session: AVCaptureSession?
    // Image preview layer, real-time display the captured image
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // The photo preview
    fileprivate var showImageContainerView: UIView?
    fileprivate var showImageView: UIImageView?
    fileprivate var picData: Data?
    
    // MARK: - 👉LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize
        setupCameraDistrict()
        
        // Set the display button
        setupUI()

    }

    // MARK: - 👉Public
    internal var callbackPicutureData: ((Data?) -> Void)?
    
    // MARK: - 👉Private
    
    /// Action buttons
    private func setupUI() {
        // take photos
        let takeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        takeButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 55)
        takeButton.setImage(#imageLiteral(resourceName: "c_takePhoto"), for: .normal)
        takeButton.addTarget(self, action: #selector(takePhotoAction), for: .touchUpInside)
        view.addSubview(takeButton)
        
        // Camera transformation
        let cameraChangeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        cameraChangeButton.setImage(#imageLiteral(resourceName: "c_changeSide"), for: .normal)
        cameraChangeButton.center = CGPoint(x: UIScreen.main.bounds.width - 50, y: takeButton.center.y)
        cameraChangeButton.addTarget(self, action: #selector(changeCameraPosition), for: .touchUpInside)
        cameraChangeButton.contentMode = .scaleAspectFit
        view.addSubview(cameraChangeButton)
        
        // The flash
        let flashChangeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        flashChangeButton.center = CGPoint(x: cameraChangeButton.center.x, y: 40)
        flashChangeButton.setImage(#imageLiteral(resourceName: "c_flashAuto"), for: .normal)
        flashChangeButton.contentMode = .scaleAspectFit
        view.addSubview(flashChangeButton)
        
        // Back button
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        backButton.center = CGPoint(x: 20, y: 40)
        backButton.setImage(#imageLiteral(resourceName: "c_back"), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        // The preview image
        showImageContainerView = UIView(frame: view.bounds)
        showImageContainerView?.backgroundColor = UIColor(white: 1, alpha: 0.7)
        view.addSubview(showImageContainerView!)
        
//        let margin: CGFloat = 15
//        let height = showImageContainerView!.bounds.height - 120 - margin * 2
        showImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        showImageView?.contentMode = .scaleAspectFit
        showImageContainerView?.addSubview(showImageView!)
        showImageContainerView?.isHidden = true
        
        // Give up, use the button
        let giveupButton = createImageOperatorButton(nil, CGPoint(x: 100, y: showImageContainerView!.bounds.height - 80), #imageLiteral(resourceName: "c_cancle"))
        giveupButton.addTarget(self, action: #selector(giveupImageAction), for: .touchUpInside)
        let ensureButton = createImageOperatorButton(nil, CGPoint(x: showImageContainerView!.bounds.width - 100, y: showImageContainerView!.bounds.height - 80), #imageLiteral(resourceName: "c_use"))
        ensureButton.addTarget(self, action: #selector(useTheImage), for: .touchUpInside)
    }
    
    private func createImageOperatorButton(_ title: String?, _ center: CGPoint, _ img: UIImage?) -> UIButton {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btn.center = center
        btn.setTitle(title, for: .normal)
        btn.setImage(img, for: .normal)
        btn.contentMode = .scaleAspectFit
        showImageContainerView?.addSubview(btn)
        return btn
    }
    
    /// Initialize the camera
    private func setupCameraDistrict() {
        // Surveillance cameras permissions
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { success in
            if !success {
                let alertVC = UIAlertController(title: "相机权限未开启", message: "设置->相机", preferredStyle: .actionSheet)
                alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)

            }
        }
        
        // The rear camera by default
        device = cameraWithPosistion(.back)
        input = try? AVCaptureDeviceInput(device: device)
        guard input != nil else {
            print("⚠️ 获取相机失败")
            return
        }
        
        imageOutput = AVCapturePhotoOutput()
        
        session = AVCaptureSession()
        session?.beginConfiguration()
        
        // Image quality
        session?.sessionPreset = AVCaptureSessionPreset1280x720
        
        // Input and output devices
        if session!.canAddInput(input) {
            session!.addInput(input)
        }
        
        if session!.canAddOutput(imageOutput) {
            session!.addOutput(imageOutput)
        }
        
        // Preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        session?.commitConfiguration()

        // Begin to view
        session?.startRunning()
    }
    
    
    /// According to the direction for the camera before and after
    ///
    /// - Parameter position: 方向
    /// - Returns: 相机
    private func cameraWithPosistion(_ position: AVCaptureDevicePosition) -> AVCaptureDevice {
        return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: position)
    }
    
    // MARK: - 👉Actions
    
    /// back
    @objc private func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    /// take photos
    @objc private func takePhotoAction() {
        let connection = imageOutput?.connection(withMediaType: AVMediaTypeVideo)
        guard connection != nil else {
            print("拍照失败")
            return
        }
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        imageOutput?.capturePhoto(with: photoSettings, delegate: self)
        
    }

    /// Camera before and after the transformatio
    @objc private func changeCameraPosition() {
        // Add flip animation to set the switch of cameras
        let animation = CATransition()
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = "oglFlip"
        
        // Reset the input and output
        let newDevice: AVCaptureDevice!
        let newInput: AVCaptureDeviceInput?
        
        let position = input?.device.position
        if position == .front {
            newDevice = cameraWithPosistion(.back)
            animation.subtype = kCATransitionFromLeft
        } else {
            newDevice = cameraWithPosistion(.front)
            animation.subtype = kCATransitionFromRight
        }
        
        // Generate a new input
        newInput = try? AVCaptureDeviceInput(device: newDevice)
        if newInput == nil {
            print("生成新的输入失败")
            return
        }
        
        previewLayer?.add(animation, forKey: nil)
        
        session?.beginConfiguration()
        session?.removeInput(input)
        if session!.canAddInput(newInput) {
            session?.addInput(newInput!)
            input = newInput
        } else {
            session?.addInput(input)
        }
        session?.commitConfiguration()
    }
    
    /// Abandon the use of images
    @objc private func giveupImageAction() {
        showImageView?.image = UIImage()
        showImageContainerView?.isHidden = true
    }
    
    /// Use pictures
    @objc private func useTheImage() {
        callbackPicutureData?(picData)
        dismiss(animated: true, completion: nil)
    }
}

extension HsuCameraViewController: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error != nil {
        print("error = \(String(describing: error?.localizedDescription))")
        } else {
            // Show the picture
            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            if imageData == nil {
                return
            }
            picData = imageData
            showImageContainerView?.isHidden = false
            showImageView?.image = UIImage(data: imageData!)
        }
    }
}
