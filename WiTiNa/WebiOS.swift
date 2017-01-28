//
//  WebiOS.swift
//  WiTiNa
//
//  Created by timothy reynolds on 12/6/16.
//  Copyright © 2016 timothy reynolds. All rights reserved.
//

import UIKit

class WebiOS : NSObject, XMLParserDelegate {
    

    let AppID = "HYGR55-W7L65UP58V"
    
    var posts = Array<Any>()
    var elements : [String : String]
    var element = String()
    var title1 = String()
    var date = String()
    var bl = false
    var parseBool = false
    var plot = ""
    var decimalApprox = ""
    var result = ""
    var plotExists = false
    var resultExists = false
    var decimalExists = false
    var img_data : Data?
    override init(){
        print("I, WebiOS, exist")
        elements = [:]
    }
    
       
    func sendToServer(_ image_data : Data, completion:@escaping (String?)->() ){
        print("At the top of sendToServer in WebiOS")
        
        let url = URL(string: "http://cs.coloradocollege.edu/~nattimwin/cgi-bin/wtn_controller")
        
        var request = URLRequest(url: url! as URL)
        
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        let fname = "I DEED EEEET"
        let mimetype = "image/png"
        //
        //body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        //body.append("Content-Disposition:form-data; name=\"photo\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        //body.append("Incoming\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"image_key\";filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using:
            String.Encoding.utf8)!)
        body.append(image_data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using:
            String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        let session = URLSession.shared
        print("Task about to begin, set initialized")
        print("session : \(session.debugDescription)")
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in guard let _:Data = data, let _:URLResponse = response , error
                == nil else {
                    print("error")
                    return
            }
            print("response: \(response.debugDescription)")
            print("Inside task, asking about httpStatus")
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                let httpStatusCode = "httpStatus.statusCode: \(httpStatus.statusCode)"
                completion(httpStatusCode)
                print("inside first if, set has been set")
            }
            else{
                let httpStatus = response as? HTTPURLResponse
                let httpStatusCode = "httpStatus.statusCode: \(httpStatus?.statusCode)"
                print("inside else, set has been set")
                completion(httpStatusCode)
            }
            //Used to diagnose what key is required/what problem might be happening
            //            let dataString = String(data: data!, encoding:
            //                String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            //            print(dataString)
            
            
        }.resume()
        
        
    }
    func generateBoundaryString() -> String {
        
        return "Boundary-\(UUID().uuidString)"
    }
    func sendToWolfram(_ input : String, completion:@escaping ()->() ){
        //print(input)
        let parsedInput = input.replacingOccurrences(of: " ", with: "")
        let url = URL(string: "http://api.wolframalpha.com/v2/query?input=\(parsedInput)&appid=\(AppID)")
        
        var request = URLRequest(url: url! as URL)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            print("Entered the completionHandler for Wolfram")
            print(response)
            do {
                print("Inside do!")
                let xmlParser = XMLParser(data : data!)
                xmlParser.delegate = self
                xmlParser.parse()
                print("done parsing? not done parsing? who knows")
                completion()
               // let parser = XMLParser(data: xmlData)
            } catch {
                print(error)
            }
            
            
            }.resume()
    }
    func downloadImage(_ url : URL, completion:@escaping ()->() ){
        //print(input)
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            print("Entered the completionHandler for Wolfram")
            print(response)
            do {
                print("Inside do!")
                self.img_data = data
                print("done parsing")
                completion()
            } catch {
                print(error)
            }
            
            
            }.resume()
    }

    
    // PARSE OUT DECIMAL APPROXIMATION, RESULT, PLOT FOR NOW
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        print(elementName)
        if (elementName as NSString).isEqual(to: "pod")
        {
            
            print("____________attributeDictTOP_______________")
            print( "attributeDict keys: \(attributeDict.keys)")
            print("____________attributeDictBOT_______________")
            if(attributeDict["title"] == "Plot" || attributeDict["title"] == "Plots") {
                self.plotExists = true
                print("final if")
            }
            if(attributeDict["title"] == "Decimal approximation") {
                self.decimalExists = true
            }
            if(attributeDict["title"] == "Result" ) {
                self.resultExists = true
            }
        }
        if(self.plotExists == true && (elementName as NSString).isEqual(to: "img")){
            print("\(elementName) found")
            plot = (attributeDict["src"] as String?)!
            print("____________img_attribute keys_______________")
            print( "attributeDict keys: \(attributeDict.keys)")
            print("____________attributeDictBOT_______________")
            print("attributeDict img_src: \(plot)")
            self.parseBool = true
        }
        if(self.decimalExists == true){
            print("decimalExists elementName : \(elementName)")
        }
        if(self.decimalExists == true && (elementName as NSString).isEqual(to: "plaintext")){
            print("\(elementName) found")
            print("____________decimal plaintext keys_______________")
            print( "attributeDict keys: \(attributeDict.keys)")
            print("____________attributeDictBOT_______________")
            //plot = (attributeDict[""] as String?)!
            //print("attributeDict img_src: \(plot)")
            self.parseBool = true
        }
        
        if(self.resultExists == true && (elementName as NSString).isEqual(to: "plaintext")){
            print("\(elementName) found")
            result = (attributeDict["src"] as String?)!
            print("____________result exists keys_______________")
            print( "attributeDict keys: \(attributeDict.keys)")
            print("____________attributeDictBOT_______________")
            print("attributeDict img_src: \(plot)")
            self.parseBool = true
        }
        
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.decimalExists == true{
            decimalApprox += string
            element += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        if (self.parseBool == true && self.decimalExists == true && (elementName as NSString).isEqual(to: "plaintext") ){
            print("element: \(self.element)")
            self.bl = false
            //self.decimalExists = false
            parser.delegate = nil
            
            
        }
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parseErrorOccurred: \(parseError)")
    }
    
}



