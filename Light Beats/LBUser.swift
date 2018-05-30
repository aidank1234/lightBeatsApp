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
    
    class func checkSession(username: String, email: String, token: String, tokenLong: String, completionHandler: @escaping ([String]?, Error?) -> Void) {
        let dict = ["username": username, "email": email, "token": token, "tokenLong": tokenLong]
        
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
}


