//
//  File.swift
//  WiTiNa
//
//  Created by timothy reynolds on 10/16/16.
//  Copyright © 2016 timothy reynolds. All rights reserved.
//

import UIKit
import AVFoundation

class DrawViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var PickerView: UIPickerView!
    @IBOutlet weak var saveNotification: UILabel!
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    var itemSelected = ""
    var operatorDictionary = [String : Data]()
    let pickerData = ["+", "-", "/", "x"]
    let fileName = "data.dat"

    override func viewDidLoad() {
        super.viewDidLoad()
        PickerView.dataSource = self
        PickerView.delegate = self
        saveNotification.text = "Unsaved"
        if readFromFile(){
            
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func touchesBegan(_ touches: Set<UITouch>,
                                    with event: UIEvent?){
        swiped = false
        if let touch = touches.first! as? UITouch {
            lastPoint = touch.location(in: self.view)
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int{
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        itemSelected = pickerData[row]
        print(itemSelected)
    }

    func readFromFile()-> Bool{
        print("inside readFromFile()")
       if let data :Data = NSKeyedArchiver.archivedData(withRootObject: operatorDictionary) as Data
       {
        print("if statement passed in readFromFile()")
        operatorDictionary = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [String : Data]
        print(operatorDictionary.count)
       // operatorDictionary = dict as Dictionary
        return true
        }
        return false
    }
    func writeToFile(){
        //writing
        NSKeyedArchiver.archiveRootObject(operatorDictionary, toFile: "data.dat")
        
    }
        
    

    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        //if(CGPoint > tempImageView.image.size.width)
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: (tempImageView.image?.size.width)!, height: (tempImageView.image?.size.height)!))
        
        // 2
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        // 3
        context?.setLineCap(CGLineCap(rawValue: Int32(1.0))!)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(.normal)
        
        // 4
        context?.strokePath()
        
        // 5
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        // 6
        swiped = true
        if let touch = touches.first! as? UITouch {
            let currentPoint = touch.location(in: view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
   override func touchesEnded(_ touches: Set<UITouch>,
                      with event: UIEvent?) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
    
    }
    @IBAction func nullifyImage(_ sender: AnyObject) {
        tempImageView.image = nil
        let imageData = operatorDictionary["plus"]
        tempImageView.image = UIImage(data:imageData!,scale:1.0)

        
    }

    @IBAction func Save(_ sender: AnyObject) {
        if tempImageView.image != nil{
            resizeImage()
            let image_data = UIImagePNGRepresentation(tempImageView.image!)
            //print("count : \(operatorDictionary.count)")
            operatorDictionary["plus"] = image_data
            //operatorDictionary.setValue(image_data, forKey: "plus")
            saveNotification.text = "Saved \(itemSelected)"
            
            //writeToFile()
            //tempImageView.image = nil
            writeToFile()
            
        }
        
    }

    func resizeImage(){
        print("resizeImage()")
        let cgSize = CGSize(width: 28.0, height: 28.0)
        //let rect = CGRect(x: 0, y: 0, width: 28, height: 28)
        //tempImageView.image!.draw(in: rect)
        tempImageView.sizeThatFits(cgSize)
        print("image.width: \(tempImageView.image?.size.width) image.height: \(tempImageView.image?.size.height)")
    }
    func returnImage(){
        let imageData = operatorDictionary["plus"]
        tempImageView.image = UIImage(data:imageData!,scale:1.0)
    }



}
