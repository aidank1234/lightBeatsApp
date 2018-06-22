//
//  SearchBeats.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/30/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

class SearchBeats: UIViewController, UISearchBarDelegate {
    var segmentControl = "song"
    let dropDown = DropDown()
    let keychain = KeychainSwift()
    var enabled = true
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    @IBOutlet weak var beatSearchBar: UISearchBar!
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if enabled == true {
            dropDown.dataSource = []
            view.addSubview(activityView)
            enabled = false
            if segmentControl == "song" {
                var songs: [String] = []
                var artists: [String] = []
                
                Alamofire.request("http://ws.audioscrobbler.com/2.0/?method=track.search&track=\(beatSearchBar.text!.replacingOccurrences(of: " ", with: "%20"))&limit=5&api_key=142effd1f45fcc682b3d477bc2f97d04&format=json", method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers:  ["Content-Type": "application/json"]).responseJSON { (response) in
                    do {
                        let json = try JSON(data: response.data!)
                        if json["results"]["trackmatches"]["track"].count > 0 {
                            for index in 0...json["results"]["trackmatches"]["track"].count - 1 {
                                songs.append(json["results"]["trackmatches"]["track"][index]["name"].string!)
                                artists.append(json["results"]["trackmatches"]["track"][index]["artist"].string!)
                            }
                            for index in 0...json["results"]["trackmatches"]["track"].count - 1 {
                                LBBeat.beatSongQuery(songRelationName: songs[index], songRelationArtist: artists[index], token: self.keychain.get("token")!, completionHandler: { (beats, error) in
                                    if error == nil {
                                        self.dropDown.dataSource.append("\(beats!) Beat(s), \(songs[index]) by \(artists[index])")
                                        if index == json["results"]["trackmatches"]["track"].count - 1 {
                                            self.dropDown.show()
                                            self.enabled = true
                                            self.activityView.removeFromSuperview()
                                            
                                            self.dropDown.selectionAction = {[weak self] (index, item) in
                                                if self?.dropDown.selectedItem != "No Results" && self?.dropDown.selectedItem?.contains("0 Beat(s)") != true {
                                                    let delimiter = " by "
                                                    let songAndArtist = (self?.dropDown.selectedItem?.components(separatedBy: delimiter))!
                                                    let beatsAndSong = songAndArtist[0].components(separatedBy: ", ")
                                                    Globals.songRelationNameDownload = beatsAndSong[1]
                                                    Globals.songRelationArtistDownload = songAndArtist[1]
                                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                                    let controller = storyboard.instantiateViewController(withIdentifier: "songBeatsResults")
                                                    self?.present(controller, animated: true, completion: nil)
                                                }
                                            }
                                        }
                                    }
                                })
                            }
                        }
                        else {
                            self.dropDown.dataSource = ["No Results"]
                            self.dropDown.show()
                            self.enabled = true
                            self.activityView.removeFromSuperview()
                        }
                    }
                    catch {
                        self.dropDown.dataSource = ["No Results"]
                        self.dropDown.show()
                        self.enabled = true
                        self.activityView.removeFromSuperview()
                    }
                }
            }
            else if segmentControl == "name" {
                LBBeat.beatNameQuery(name: beatSearchBar.text!, token: keychain.get("token")!) { (results, error) in
                    if error == nil {
                        self.dropDown.dataSource = results as! [String]
                    }
                    else {
                        self.dropDown.dataSource = ["No Results"]
                    }
                    self.activityView.removeFromSuperview()
                    self.enabled = true
                    self.dropDown.show()
                    
                    self.dropDown.selectionAction = {[weak self] (index, item) in
                        if self?.dropDown.selectedItem != "No Results" {
                            
                            self?.view.addSubview((self?.activityView)!)
                            LBBeat.beatByName(name: (self?.dropDown.selectedItem!)!, token: (self?.keychain.get("token")!)!) { (beat, error) in
                                if error == nil {
                                    Globals.playsDownload = (beat?.plays)!
                                    Globals.ratingDownload = (beat?.rating)!
                                    Globals.beatNameDownload = (self?.dropDown.selectedItem!)!
                                    Globals.beatLengthsDownload = (beat?.beatLengths)!
                                    Globals.songRelationDownload = (beat?.songRelation)!
                                    Globals.songStartTimeDownload = (beat?.songStartTime)!
                                    Globals.songRelationArtistDownload = (beat?.songRelationArtist)!
                                    Globals.songRelationNameDownload = (beat?.songRelationName)!
                                    Globals.createdByDownload = (beat?.createdBy)!
                                    
                                    self?.activityView.removeFromSuperview()
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "hostBeat")
                                    self?.present(controller, animated: true, completion: nil)
                                }
                                else {
                                    let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self?.present(alert, animated: true, completion: {
                                        self?.activityView.removeFromSuperview()
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    @IBOutlet weak var segments: UISegmentedControl!
    @IBAction func segmentValueChanged(_ sender: Any) {
        
        switch segments.selectedSegmentIndex
        {
        case 0:
            segmentControl = "song"
        case 1:
            segmentControl = "name"
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beatSearchBar.delegate = self
        dropDown.anchorView = beatSearchBar
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
