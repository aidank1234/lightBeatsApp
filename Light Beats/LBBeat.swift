//
//  LBBeat.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/23/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import Foundation
import Alamofire

class LBBeat {
    var name: String?
    var beatStart: Int?
    var beatLengths: [Double]?
    var brightness: [Double]?
    var songStartTime: Int?
    var songRelation: Bool?
    var songRelationName: String?
    var songRelationArtist: String?
    var plays: Int?
    var rating: Double?
    var createdBy: String?
    
    init(name: String, beatStart: Int, beatLengths: [Double], brightness: [Double], songStartTime: Int, songRelation: Bool, songRelationName: String, songRelationArtist: String, plays: Int, rating: Double, createdBy: String) {
        self.name = name
        self.beatStart = beatStart
        self.beatLengths = beatLengths
        self.songRelationName = songRelationName
        self.songRelationArtist = songRelationArtist
        self.brightness = brightness
        self.songStartTime = songStartTime
        self.songRelation = songRelation
        self.plays = plays
        self.rating = rating
        self.createdBy = createdBy
        
    }
    
    class func newBeat(name: String, beatStart: Int, beatLengths: [Double], brightness: [Double], songStartTime: Int, songRelation: Bool, songRelationName: String, songRelationArtist: String, createdBy: String, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["name": name, "beatStart": beatStart, "beatLengths": beatLengths, "brightness": brightness, "songStartTime": songStartTime, "songRelation": songRelation, "songRelationName": songRelationName, "songRelationArtist": songRelationArtist, "createdBy": createdBy, "token": token] as [String : Any]
        
        Alamofire.request("\(Globals.baseURL)/beat/newBeat", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                completionHandler(statusCode, nil)
            }
            else {
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func beatByName(name: String, token: String, completionHandler: @escaping (LBBeat?, Error?) -> Void) {
        let dict = ["name": name, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/beat/beatByName", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    let downloadedBeat = LBBeat(name: json["name"]! as! String, beatStart: json["beatStart"]! as! Int, beatLengths: json["beatLengths"]! as! [Double], brightness: json["brightness"]! as! [Double], songStartTime: json["songStartTime"]! as! Int, songRelation: json["songRelation"]! as! Bool, songRelationName: json["songRelationName"]! as! String, songRelationArtist: json["songRelationArtist"]! as! String, plays: json["plays"]! as! Int, rating: json["rating"]! as! Double, createdBy: json["createdBy"]! as! String)
                    completionHandler(downloadedBeat, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler(nil, badStatusError)
                }
                
            }
            else {
                completionHandler(nil, response.error)
            }
        }
    }
    
    class func validateName(name: String, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["name": name, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/beat/validateName", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).response { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                completionHandler(statusCode, nil)
            }
            else {
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func beatNameQuery(name: String, token: String, completionHandler: @escaping ([String?], Error?) -> Void) {
        let dict = ["name": name, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/beat/beatNameQuery", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    var nameArray: [String] = []
                    let result = response.result.value
                    let json = result as! [NSDictionary]
                    let length = json.count
                    if length != 0 {
                        for index in 0...length - 1 {
                        nameArray.append(json[index]["name"] as! String)
                        }
                    }
                    else {
                        nameArray.append("No Results")
                    }
                    completionHandler(nameArray, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler(["No Results"], badStatusError)
                }
            }
            else {
                completionHandler(["No Results"], response.error)
            }
        }
    }
    
    class func beatSongQuery(songRelationName: String, songRelationArtist: String, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["songRelationName": songRelationName, "songRelationArtist": songRelationArtist, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/beat/beatSongQuery", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = result as! NSDictionary
                    completionHandler(json["results"] as? Int, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler(0, nil)
                }
            }
            else {
                completionHandler(0, response.error)
            }
        }
    }
    
    class func beatsBySong(songRelationName: String, songRelationArtist: String, token: String, completionHandler: @escaping ([String?], Error?) -> Void) {
        let dict = ["songRelationName": songRelationName, "songRelationArtist": songRelationArtist, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/beat/beatsBySong", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
            let statusCode = response.response?.statusCode
                if statusCode == 200 {
                    let result = response.result.value
                    let json = try! JSON(data: response.data!)
                    print(json)
                    var results: [String] = []
                    for index in 0...Int(json["amount"].int! - 1) {
                        results.append(json["results"][index]["name"].string!)
                    }
                    completionHandler(results, nil)
                }
                else {
                    let badStatusError = NSError(domain: "", code: statusCode!, userInfo: nil)
                    completionHandler([""], nil)
                }
            }
            else {
                completionHandler([""], response.error)
            }
            
        }
    }
    
    class func updateRating(name: String, rating: Double, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["name": name, "rating": rating, "token": token] as [String : Any]
        
        Alamofire.request("\(Globals.baseURL)/beat/updateRating", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
            if response.error == nil {
                let statusCode = response.response?.statusCode
                completionHandler(statusCode, nil)
            }
            else {
                completionHandler(-1, response.error)
            }
        }
    }
    
    class func removeByName(name: String, username: String, token: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        let dict = ["name": name, "username": username, "token": token]
        
        Alamofire.request("\(Globals.baseURL)/beat/deleteByName", method: HTTPMethod.post, parameters: dict, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
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
