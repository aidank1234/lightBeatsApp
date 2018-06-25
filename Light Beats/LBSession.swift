//
//  LBSession.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/4/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import Foundation
import Alamofire

class LBSession {
    class func newSession(lightBeat: String, username: String, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["lightBeat": lightBeat, "username": username, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/session/newSession", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    let sessionCode = json["code"] as! Int
                    completionHandler(sessionCode, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler(-1, badStatusError)
                }
            }
            else {
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func joinSession(code: Int, token: String, completionHandler: @escaping (LBBeat?, Error?) -> Void) {
        let dict = ["code": code, "token": token] as [String : Any]
        
        Alamofire.request("\(Globals.baseURL)/session/joinSession", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response!.statusCode
                print(statusCode)
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    let dict2 = ["name": json["lightBeat"] as! String, "token": token]
                    
                    Alamofire.request("\(Globals.baseURL)/beat/beatByName", method: HTTPMethod.post, parameters: dict2, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON(completionHandler: { (response2) in
                        if response2.error == nil {
                        let statusCode2 = response2.response?.statusCode
                        if statusCode2 == 200 {
                            let result2 = response2.result.value
                            let json2 = result2 as! NSDictionary
                            
                            let downloadedBeat = LBBeat(name: json2["name"]! as! String, beatStart: json2["beatStart"]! as! Int, beatLengths: json2["beatLengths"]! as! [Double], brightness: json2["brightness"]! as! [Double], songStartTime: json2["songStartTime"]! as! Int, songRelation: json2["songRelation"]! as! Bool, songRelationName: json2["songRelationName"]! as! String, songRelationArtist: json2["songRelationArtist"]! as! String, plays: json2["plays"]! as! Int, rating: json2["rating"]! as! Double, createdBy: json2["createdBy"]! as! String)
                            completionHandler(downloadedBeat, nil)
                        }
                        else {
                            let badStatusError = NSError(domain: "", code: statusCode2!, userInfo: nil)
                            completionHandler(nil, badStatusError)
                        }
                        }
                        else {
                            completionHandler(nil, response2.error)
                        }
                    })
                }
                else {
                    print("MADE BAD STATUS")
                    let badStatusError = NSError(domain: "", code: statusCode, userInfo: nil)
                    completionHandler(nil, badStatusError)
                }
            }
            else {
                completionHandler(nil, response.error)
            }
        }
    }
    
    class func checkLive(code: Int, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["code": code, "token": token] as [String : Any]
        
        Alamofire.request("\(Globals.baseURL)/session/checkLive", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    if json["started"] as! Bool == true {
                        completionHandler(json["dateStarted"] as! Int, nil)
                    }
                    else {
                        completionHandler(-1, nil)
                    }
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler(-1, badStatusError)
                }
            }
            else {
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func startSession(code: Int, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["code": code, "token": token] as [String : Any]
        
        Alamofire.request("\(Globals.baseURL)/session/startSession", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    completionHandler(json["subscribers"]! as! Int, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler(-1, badStatusError)
                }
            }
            else {
                print(response.error!)
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func checkSubscribers(code: Int, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["code": code, "token": token] as [String : Any]
        
        Alamofire.request("\(Globals.baseURL)/session/checkSubscribers", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    completionHandler(json["subscribers"]! as! Int, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler(-1, badStatusError)
                }
            }
            else {
                print(response.error!)
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func deleteSession(code: Int, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["code": code, "token": token] as [String : Any]
        
        Alamofire.request("\(Globals.baseURL)/session/deleteSession", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                completionHandler(statusCode, nil)
            }
            else {
                completionHandler(-1, response.error)
            }
        }
    }
}
