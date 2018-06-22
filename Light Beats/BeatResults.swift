//
//  BeatResults.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/4/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class BeatResults: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var beatsTitles: [String] = []
    let keychain = KeychainSwift()
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beatsTitles.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellText = beatsTitles[indexPath.row]
        beatResultsTableView.allowsSelection = false
        view.addSubview(activityView)
        LBBeat.beatByName(name: cellText, token: keychain.get("token")!) { (beat, error) in
            if error == nil {
                Globals.playsDownload = (beat?.plays)!
                Globals.ratingDownload = (beat?.rating)!
                Globals.beatNameDownload = cellText
                Globals.beatLengthsDownload = (beat?.beatLengths)!
                Globals.songRelationDownload = (beat?.songRelation)!
                Globals.songStartTimeDownload = (beat?.songStartTime)!
                Globals.songRelationArtistDownload = (beat?.songRelationArtist)!
                Globals.songRelationNameDownload = (beat?.songRelationName)!
                Globals.createdByDownload = (beat?.createdBy)!
                
                self.activityView.removeFromSuperview()
                self.beatResultsTableView.allowsSelection = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "hostBeat")
                self.present(controller, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.beatResultsTableView.allowsSelection = true
                })
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = beatResultsTableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(beatsTitles[indexPath.row])"
        return cell
    }
    
    @IBOutlet weak var beatResultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beatResultsTableView.delegate = self
        beatResultsTableView.dataSource = self
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
        loadBeats()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadBeats() {
        view.addSubview(activityView)
        LBBeat.beatsBySong(songRelationName: Globals.songRelationNameDownload, songRelationArtist: Globals.songRelationArtistDownload, token: keychain.get("token")!) { (beatNames, error) in
            if error == nil {
                print(beatNames)
                self.beatsTitles = beatNames as! [String]
                self.activityView.removeFromSuperview()
                self.beatResultsTableView.reloadData()
            }
            else {
                let alert = UIAlertController(title: "Failure", message: "Unable to load beats", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "beatSelector")
                    self.present(controller, animated: true, completion: nil)
                })
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
