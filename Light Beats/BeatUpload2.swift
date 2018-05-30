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
    @IBAction func textFieldSearch(_ sender: Any) {
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
                            dropDown.dataSource.append("\(songs[index]) - \(artists[index])")
                        }
                    }
                    else {
                        dropDown.dataSource = ["No Results"]
                    }
                }
                catch {
                    dropDown.dataSource = ["No Results"]
                }
                dropDown.dismissMode = .onTap
                dropDown.selectionAction = {[weak self] (index, item) in
                    if dropDown.selectedItem != "No Results" {
                        self?.searchSongField.text = dropDown.selectedItem
                    }
                }
                dropDown.show()
                
            }
        }
    }
    @IBOutlet weak var searchSongField: UITextField!
    @IBAction func searchSongEditingEnd(_ sender: Any) {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchSongField.delegate = self
        searchSongField.returnKeyType = .search
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
