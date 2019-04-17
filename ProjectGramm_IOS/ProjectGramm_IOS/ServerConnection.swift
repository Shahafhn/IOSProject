//
//  ServerConnection.swift
//  ProjectGramm_IOS
//
//  Created by hackeru on 06/04/2019.
//  Copyright © 2019 fluffiels. All rights reserved.
//

import Foundation

class ServerConnection{
    
    static let SUCCESS:Int = 200
    static let USER_EXISTS:Int = 401
    static let USER_NOT_FOUND:Int = 404
    static let NO_INTERNET:Int = 500
    static let currentIP:String = "109.67.228.242"
    
    
    static func login(isNewUser:Bool, username:String, password:String,onComplete: @escaping (Int)->Void){
        var currentLink:String = "http://\(currentIP):8080/project?"
        currentLink.append("action=\(isNewUser ? "register" : "login")")
        currentLink.append("&user=\(username.lowercased())&pass=\(password.lowercased())")
        doGetRequest(link: currentLink) { (data:Data?, response:URLResponse?, error:Error?) in
            let responseCode:Int
            if let httpResponse = response as? HTTPURLResponse{
                responseCode = httpResponse.statusCode
            }else{
                responseCode = 500
            }
            DispatchQueue.main.async(execute: {
                onComplete(responseCode)
            })
        }
    }
    
    static func searchNames(look:String,onComplete: @escaping ([(String,Int)]?, Int)->Void){
        var currentLink:String = "http://\(currentIP):8080/project?action=searchs"
        currentLink.append("&look=\(look.lowercased())")
        doGetRequest(link: currentLink) { (data:Data?, response:URLResponse?, error:Error?) in
            if let theData = data{
                let strings:String = String(data: theData, encoding: String.Encoding.utf8)!
                let splitted = strings.components(separatedBy: CharacterSet(arrayLiteral: Unicode.Scalar(124)))
                var profiles:[(String,Int)] = []
                var max = 0
                for s in splitted{
                    var extracted = s.components(separatedBy: CharacterSet(arrayLiteral: Unicode.Scalar(92)))
                    profiles.append((String(extracted[0]),Int(String(extracted[1]))!))
                    max += 1
                }
                DispatchQueue.main.async(execute: {
                    onComplete(splitted.capacity == 0 ? nil : profiles, max)
                })
            }
        }
    }
    
    static func getImageData(name:String,num:Int,max:Int,onComplete: @escaping (Data,Int)->Void){
        var currentLink:String = "http://\(currentIP):8080/project?action=getpics"
        currentLink.append("&profile=\(name)&position=\(max - 1 - num)")
        doPostRequest(link: currentLink, handler: { (data, response, error) in
            onComplete(data!,num)
        }, isUploading: false, data: nil)
    }
    
    static func uploadImageData(name:String,data:Data,onComplete: @escaping ()->Void){
        var currentLink:String = "http://\(currentIP):8080/project?action=upload"
        currentLink.append("&user=\(name)")
        doPostRequest(link: currentLink, handler: { (data, response, error) in
            onComplete()
        }, isUploading: true, data: data)
    }
    
    static func doPostRequest(link:String,handler: @escaping (Data?,URLResponse?,Error?)->Void,isUploading:Bool,data:Data?){
        let url = URL(string: link)!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        let session = URLSession(configuration: URLSessionConfiguration.default)
        if !isUploading{
            let task = session.dataTask(with: urlRequest, completionHandler: handler)
            task.resume()
        }else{
            let task = session.uploadTask(with: urlRequest, from: data!, completionHandler: handler)
            task.resume()
        }
        
    }
    
    static func doGetRequest(link:String,handler: @escaping (Data?,URLResponse?,Error?) -> Void){
        let url = URL(string: link)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        let session:URLSession = URLSession(configuration: config)
        let task = session.dataTask(with: url!, completionHandler: handler)
        task.resume()
    }
}
