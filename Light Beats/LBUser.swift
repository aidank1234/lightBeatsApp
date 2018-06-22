//
//  LBUser.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/23/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import Foundation
import Alamofire

struct Globals {
    static var baseURL = "http://10.0.0.220:3000"
    
    static var beatNameUpload = ""
    static var beatStartUpload = -1
    static var beatLengthsUpload: [Double] = []
    static var brightnessUpload: [Double] = []
    static var songStartTimeUpload = -1
    static var songRelationUpload = false
    
    static var beatNameDownload = ""
    static var beatLengthsDownload: [Double] = []
    static var songStartTimeDownload = -1
    static var songRelationDownload = false
    static var songRelationArtistDownload = ""
    static var songRelationNameDownload = ""
    static var playsDownload = 0
    static var ratingDownload = -1.0
    static var createdByDownload = ""
}


class LBUser {
    var username: String?
    var email: String?
    var beats: [String] = []
    var token: String?
    var tokenLong: String?
    
    init(username: String, email: String, beats: [String]) {
        self.username = username
        self.email = email
        self.beats = beats
    }
    
    class func createUser(username: String, password: String, email: String, completionHandler: @escaping ([String]?, Error?) -> Void) {
        let dict = ["username": username, "password": password, "email": email]
        
        Alamofire.request("\(Globals.baseURL)/user/createUser", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    var stringArray = ["", ""]
                    let result = response.result.value
                    let json = result as! NSDictionary
                    stringArray[0] = json["token"]! as! String
                    stringArray[1] = json["tokenLong"]! as! String
                    completionHandler(stringArray, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    let stringArray = [""]
                    completionHandler(stringArray, badStatusError)
                }
            }
            else {
                let stringArray = [""]
                completionHandler(stringArray, response.error)
            }
        }
    }
    
    class func validateUsername(username: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["username": username]
        
        Alamofire.request("\(Globals.baseURL)/user/validateUsername", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                completionHandler(statusCode, nil)
            }
            else {
                completionHandler(-1, nil)
            }
        }
    }
    
    class func logIn(username: String, password: String, completionHandler: @escaping ([String]?, Error?) -> Void) {
        let dict = ["username": username, "password": password]
        
        Alamofire.request("\(Globals.baseURL)/user/signIn", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    var stringArray = ["", ""]
                    let result = response.result.value
                    let json = result as! NSDictionary
                    stringArray[0] = json["token"]! as! String
                    stringArray[1] = json["tokenLong"]! as! String
                    completionHandler(stringArray, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    let stringArray = [""]
                    completionHandler(stringArray, badStatusError)
                }
            }
            else {
                let stringArray = [""]
                completionHandler(stringArray, response.error)
            }
        }
    }
    
    class func checkSession(username: String, token: String, tokenLong: String, completionHandler: @escaping ([String]?, Error?) -> Void) {
        let dict = ["username": username, "token": token, "tokenLong": tokenLong]
        
        Alamofire.request("\(Globals.baseURL)/user/checkSession", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    var stringArray = ["", ""]
                    let result = response.result.value
                    let json = result as! NSDictionary
                    stringArray[0] = json["token"]! as! String
                    stringArray[1] = json["tokenLong"]! as! String
                    completionHandler(stringArray, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    let stringArray = [""]
                    completionHandler(stringArray, badStatusError)
                }
            }
            else {
                let stringArray = [""]
                completionHandler(stringArray, response.error)
            }
        }
    }
    
    class func addBeat(username: String, beatName: String, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["username": username, "token": token, "beatName": beatName]
        
        Alamofire.request("\(Globals.baseURL)/user/addBeat", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                completionHandler(statusCode, nil)
            }
            else {
                print(response.error!)
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func getBeats(username: String, token: String, completionHandler: @escaping ([String?], Error?) -> Void) {
        let dict = ["username": username, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/user/getBeats", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    completionHandler(json["beats"] as! [String], nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    let stringArray = [""]
                    completionHandler(stringArray, badStatusError)
                }
            }
            else {
                let stringArray = [""]
                completionHandler(stringArray, response.error)
            }
        }
    }
    
    class func getShortTokens(token: String, tokenLong: String, completionHandler: @escaping ([String]?, Error?) -> Void) {
        UserDefaults.standard.removeObject(forKey: "username")
        let dict = ["token": token, "tokenLong": tokenLong]
        
        Alamofire.request("\(Globals.baseURL)/user/getShortTokens", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    var stringArray = ["", ""]
                    let result = response.result.value
                    let json = result as! NSDictionary
                    stringArray[0] = json["token"]! as! String
                    stringArray[1] = json["tokenLong"]! as! String
                    completionHandler(stringArray, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    let stringArray = [""]
                    completionHandler(stringArray, badStatusError)
                }
            }
            else {
                let stringArray = [""]
                completionHandler(stringArray, response.error)
            }
        }
    }
}


