//
//  BeatUpload2.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/26/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import DropDown
import Alamofire

class BeatUpload2: UIViewController, UITextFieldDelegate {
    let keychain = KeychainSwift()
    var canSearchSongs = true
    var selected = false
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var songAndArtist: [String] = []
    
    @IBOutlet weak var songStartTimeMinutesField: UITextField!
    @IBOutlet weak var songStartTimeSecondsField: UITextField!
    @IBAction func searchSongEditingBegan(_ sender: Any) {
        selected = false
    }
    @IBAction func textFieldSearch(_ sender: Any) {
       searchSongs()
        selected = true
    }
    @IBOutlet weak var searchSongField: UITextField!
    @IBAction func searchSongEditingEnd(_ sender: Any) {
        if selected == false {
            searchSongs()
        }
    }
    @IBOutlet weak var finishButton: UIButton!
    @IBAction func finishButtonTapped(_ sender: Any) {
        view.addSubview(activityView)
        finishButton.isEnabled = false
        canSearchSongs = false
        
        if songAndArtist.count < 2 {
            let alert = UIAlertController(title: "Failure", message: "Please ensure that you select a song", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true) {
                self.activityView.removeFromSuperview()
                self.finishButton.isEnabled = true
                self.canSearchSongs = true
            }
        }
        else if songStartTimeMinutesField.text! == "" || songStartTimeSecondsField.text! == "" {
            let alert = UIAlertController(title: "Failure", message: "Please ensure that you enter a start time for the song", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true) {
                self.activityView.removeFromSuperview()
                self.finishButton.isEnabled = true
                self.canSearchSongs = true
            }
        }
        else if Int(songStartTimeMinutesField.text!) == nil || Int(songStartTimeSecondsField.text!) == nil {
            let alert = UIAlertController(title: "Failure", message: "Please ensure that the start time is a number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true) {
                self.activityView.removeFromSuperview()
                self.finishButton.isEnabled = true
                self.canSearchSongs = true
            }
        }
        else {
            Alamofire.request("http://ws.audioscrobbler.com/2.0/?method=track.getInfo&track=\(songAndArtist[0].replacingOccurrences(of: " ", with: "%20"))&artist=\(songAndArtist[1].replacingOccurrences(of: " ", with: "%20"))&api_key=142effd1f45fcc682b3d477bc2f97d04&format=json", method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
                do {
                    let json = try JSON(data: response.data!)
                    let duration = Int(json["track"]["duration"].string!)!/1000
                    if Int(self.songStartTimeMinutesField.text!)! * 60 + Int(self.songStartTimeSecondsField.text!)! > duration {
                        let alert = UIAlertController(title: "Failure", message: "Please ensure that the start time is less than the song's duration", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true) {
                            self.activityView.removeFromSuperview()
                            self.finishButton.isEnabled = true
                            self.canSearchSongs = true
                        }
                    }
                    else {
                        let track = json["track"]["name"].string!
                        let artist = json["track"]["artist"]["name"].string!
                        let startTime = Int(self.songStartTimeMinutesField.text!)! * 60 + Int(self.songStartTimeSecondsField.text!)!
                
                        LBBeat.newBeat(name: Globals.beatNameUpload, beatStart: Globals.beatStartUpload, beatLengths: Globals.beatLengthsUpload, brightness: Globals.brightnessUpload, songStartTime: startTime, songRelation: true, songRelationName: track, songRelationArtist: artist, createdBy: UserDefaults.standard.string(forKey: "username")!, token: self.keychain.get("token")!, completionHandler: { (response, error) in
                            if error == nil {
                                if response == 200 {
                                    self.addBeat()
                                }
                                else {
                                    let alert = UIAlertController(title: "Failure", message: "An error occured during the upload", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: {
                                        self.activityView.removeFromSuperview()
                                        self.finishButton.isEnabled = true
                                        self.canSearchSongs = true
                                    })
                                }
                            }
                            else {
                                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: {
                                    self.activityView.removeFromSuperview()
                                    self.finishButton.isEnabled = true
                                    self.canSearchSongs = true
                                })
                            }
                        })
                    }
                }
                catch {
                    
                }
            }
        }
    }
    func addBeat() {
        LBUser.addBeat(username: UserDefaults.standard.string(forKey: "username")!, beatName: Globals.beatNameUpload, token: self.keychain.get("token")!, completionHandler: { (resp, err) in
            if err != nil {
                let alert = UIAlertController(title: "Failure", message: err?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.finishButton.isEnabled = true
                    self.canSearchSongs = true
                })
            }
            else {
                if resp == 200 {
                    self.activityView.removeFromSuperview()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "firstScreen")
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Failure", message: "An error occured during the upload", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: {
                        self.activityView.removeFromSuperview()
                        self.finishButton.isEnabled = true
                        self.canSearchSongs = true
                    })
                }
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchSongField.delegate = self
        searchSongField.returnKeyType = .search
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
        songStartTimeMinutesField.keyboardType = UIKeyboardType.numberPad
        songStartTimeSecondsField.keyboardType = UIKeyboardType.numberPad
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func searchSongs() {
        if canSearchSongs == true {
            finishButton.isEnabled = false
            canSearchSongs = false
            view.addSubview(activityView)
        if searchSongField.text! != "" {
            let dropDown = DropDown()
            var songs: [String] = []
            var artists: [String] = []
            dropDown.anchorView = searchSongField
            dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
            Alamofire.request("http://ws.audioscrobbler.com/2.0/?method=track.search&track=\(searchSongField.text!.replacingOccurrences(of: " ", with: "%20"))&limit=5&api_key=142effd1f45fcc682b3d477bc2f97d04&format=json", method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json"]).responseJSON { (response) in
                do {
                    let json = try JSON(data: response.data!)
                    if json["results"]["trackmatches"]["track"].count > 0 {
                        for index in 0...json["results"]["trackmatches"]["track"].count - 1 {
                            songs.append(json["results"]["trackmatches"]["track"][index]["name"].string!)
                            artists.append(json["results"]["trackmatches"]["track"][index]["artist"].string!)
                        }
                        for index in 0...json["results"]["trackmatches"]["track"].count - 1 {
                            dropDown.dataSource.append("\(songs[index]) by \(artists[index])")
                        }
                    }
                    else {
                        dropDown.dataSource = ["No Results"]
                        self.finishButton.isEnabled = true
                        self.canSearchSongs = true
                        self.activityView.removeFromSuperview()
                    }
                }
                catch {
                    dropDown.dataSource = ["No Results"]
                    self.finishButton.isEnabled = true
                    self.canSearchSongs = true
                    self.activityView.removeFromSuperview()
                }
                dropDown.dismissMode = .onTap
                dropDown.selectionAction = {[weak self] (index, item) in
                    if dropDown.selectedItem != "No Results" {
                        let delimiter = " by "
                        self?.songAndArtist = (dropDown.selectedItem?.components(separatedBy: delimiter))!
                        self?.searchSongField.text = dropDown.selectedItem
                    }
                }
                dropDown.show()
                self.finishButton.isEnabled = true
                self.canSearchSongs = true
                self.activityView.removeFromSuperview()
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
