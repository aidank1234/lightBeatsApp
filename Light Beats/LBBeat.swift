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
    
    init(name: String, beatStart: Int, beatLengths: [Double], brightness: [Double], songStartTime: Int, songRelation: Bool, songRelationName: String, songRelationArtist: String) {
        self.name = name
        self.beatStart = beatStart
        self.beatLengths = beatLengths
        self.songRelationName = songRelationName
        self.songRelationArtist = songRelationArtist
        self.brightness = brightness
        self.songStartTime = songStartTime
        self.songRelation = songRelation
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
                    let downloadedBeat = LBBeat(name: json["name"]! as! String, beatStart: json["beatStart"]! as! Int, beatLengths: json["beatLengths"]! as! [Double], brightness: json["brightness"]! as! [Double], songStartTime: json["songStartTime"]! as! Int, songRelation: json["songRelation"]! as! Bool, songRelationName: json["songRelationName"]! as! String, songRelationArtist: json["songRelationArtist"]! as! String)
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
}
