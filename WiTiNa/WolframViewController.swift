//
//  WolframViewController.swift
//  WiTiNa
//
//  Created by timothy reynolds on 12/19/16.
//  Copyright © 2016 timothy reynolds. All rights reserved.
//

import UIKit

class WolframViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var image: UIImageView!
    
    let webiOS = WebiOS()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.webiOS.sendToWolfram(self.textView.text){
            print("wolfram response, inside textViewDidEnd: \(self.webiOS.element)")
            if(self.webiOS.plotExists){
                print("plotURL = \(self.webiOS.plot)")
                let plotURL = URL(string: self.webiOS.plot)
                self.webiOS.downloadImage(plotURL!){
                print("download completed")
                if(self.webiOS.img_data != nil){
                    print("displaying plot now")
                    self.image.image = UIImage(data : self.webiOS.img_data!)

                }
                else{
                    print("img_data = nil")
                }
                    
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
