//
//  ViewController.swift
//  WiTiNa
//
//  Created by timothy reynolds on 10/5/16.
//  Copyright © 2016 timothy reynolds. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    /*TO-DO: 
     image download from Wolfram
     request solution to typed problem
    */
    
    @IBOutlet weak var toolbar: UIToolbar!

    @IBOutlet weak var serverMessage: UITextField!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var capture: UIButton!
    
    @IBOutlet weak var rect: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var image = UIImage()
    var session: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var cameraOn = false
    var secondIteration = false
    var captureDevice : AVCaptureDevice!
    
    let webiOS = WebiOS()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        capture.isHidden = false
        // Do any additional setup after loading the view, typically from a nib.
        serverMessage.isHidden = true
        
        self.toolbar.setBackgroundImage(UIImage(),forToolbarPosition: .any, barMetrics: .default)
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        self.navigationController?.navigationBar.setBackgroundImage( UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        rect.layer.borderColor = UIColor.yellow.cgColor
        rect.layer.borderWidth = 2

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear has been called")
        
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        self.captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            
            print("backCamera found")
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        if error == nil && session.canAddInput(input) {
            session.addInput(input)
            print("input added to session")
            
            stillImageOutput = AVCapturePhotoOutput()
            if session.canAddOutput(stillImageOutput) {
                session.addOutput(stillImageOutput)
                print("stillimageOutput added")
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
                videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                

                cameraView.layer.addSublayer(videoPreviewLayer)
                print("session starting...")
                
                session.startRunning()
               
                
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //videoPreviewLayer.frame = cameraView.bounds
        self.videoPreviewLayer.frame = self.cameraView.bounds
        

    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            photo.image = UIImage(data: dataImage)
            print(UIImage(data: dataImage)?.size)
        } else {
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        let screenSize = cameraView.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: cameraView).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: cameraView).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .ContinuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .Locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
        }
    }
    
    @IBAction func refreshPhoto(_ sender: Any) {
        session.stopRunning()
        self.photo.image = nil
        self.capture.isHidden = false
        self.capture.isEnabled = true
        self.session.startRunning()
        
    }
    @IBAction func capturePhoto(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
        
        self.capture.isHidden = true
        self.capture.isEnabled = false
    
        
    }
    @IBAction func Save(_ sender: AnyObject) {
        if(photo.image != nil){
            activityIndicator.startAnimating()
            print("is animating:\(activityIndicator.isAnimating)")
            print("animation started")
            if (photo.image == nil){
                return
            }
            
            let image_data = UIImagePNGRepresentation(photo.image!)
            
            if(image_data == nil){
                return
            }
            print("above webiOS.sendToServer")
            webiOS.sendToServer(image_data!){ httpStatusCode in
                if let httpStatusCode = httpStatusCode {
                
                    print("below webiOS.sendToServer")
                    self.activityIndicator.stopAnimating()
                    self.serverMessage.isHidden = false
                    self.serverMessage.text = httpStatusCode
                    print("ServerMessage.text set!")
                    // sendToServer(image_data: image_data!)
                }
                else{
                    self.serverMessage.text = "Request Failed"
                }
            }
            
        }
        webiOS.sendToWolfram("Pi"){ void in
            print("my webiOS element from ViewController: \(self.webiOS.element)")
        }
            
    }
    
}
