//
//  ViewController.swift
//  WiTiNa
//
//  Created by timothy reynolds on 10/5/16.
//  Copyright © 2016 timothy reynolds. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var serverMessage: UITextField!
    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePicker: UIImagePickerController!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        serverMessage.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Save(_ sender: AnyObject) {
        if(photo.image != nil){
            activityIndicator.startAnimating()
            print("is animating:\(activityIndicator.isAnimating)")
            print("animation started")
            uploadRequest()
        }
    }
    
    
    @IBAction func Camera(_ sender: AnyObject) {
        serverMessage.isHidden = true
        takePhoto()
    }
    func takePhoto(){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photo.contentMode = .scaleToFill
            photo.image = pickedImage
        }
        
         picker.dismiss(animated: true, completion: nil)
    }
    func uploadRequest()
    {
        var request = URLRequest(url: URL(string: "http://cs.coloradocollege.edu/~nattimwin/cgi-bin/wtn_controller")!)
        request.httpMethod = "POST"
        let body = NSMutableData()
        let boundary = generateBoundaryString()
        if (photo.image == nil)
        {
            return
        }
        
        let image_data = UIImagePNGRepresentation(photo.image!)
        
        
        if(image_data == nil)
        {
            return
        }
        
       
        let fname = "file_1"
        let mimetype = "image/png"
        
        //define the data post parameter
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        

        request.httpBody = body as Data
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                self.serverMessage.isHidden = false
                self.serverMessage.text = "httpStatus.statusCode: \(httpStatus.statusCode)"
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            self.activityIndicator.stopAnimating()
            print("is animating:\(self.activityIndicator.isAnimating)")
        }
       
        task.resume()
        
        
    }
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
