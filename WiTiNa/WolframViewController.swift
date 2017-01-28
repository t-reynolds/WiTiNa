//
//  WolframViewController.swift
//  WiTiNa
//
//  Created by timothy reynolds on 12/19/16.
//  Copyright © 2016 timothy reynolds. All rights reserved.
//

import UIKit

class WolframViewController: UIViewController, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var image: UIImageView!
    
    
    
    let reuseIdentifier = "cell" // also enter this string as the cell identifier in the storyboard
    var items = ["Plot", "Decimal Approximation", "Result", "4", "5", "6"]

    
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
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! WolframViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.myLabel.text = self.items[indexPath.item]
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    //MARK: - Handle user interaction with Cells
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.red
    }
    
    // change background color back when user releases touch
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.cyan
    }
    
    // MARK: - textView methods
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
                self.items[0] = "Plot"
                self.collectionView.delegate = self
                self.collectionView.isHidden = false
                
                if(self.webiOS.img_data != nil){
                    print("displaying plot now")
                    self.image.image = UIImage(data : self.webiOS.img_data!)

                }
                else{
                    print("img_data = nil")
                }
                    
                }
            }
            if(self.webiOS.decimalExists){
                print("decimalApprox = \(self.webiOS.decimalApprox.replacingOccurrences(of: "\n", with: ""))")
                
                
            }
            
        }
       
        /*var text = self.webiOS.decimalApprox.replacingOccurrences(of: "\n", with: "")
        let index = text.index(text.startIndex, offsetBy: 5)
        text = text.substring(to: index)
        self.textView.text = text */
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
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
