//
//  MyBeats.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/30/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class MyBeats: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var myBeatsTitles: [String] = []
    let keychain = KeychainSwift()
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myBeatsTitles.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myBeatsTableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(myBeatsTitles[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellText = myBeatsTitles[indexPath.row]
        myBeatsTableView.allowsSelection = false
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
                self.myBeatsTableView.allowsSelection = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "hostBeat")
                self.present(controller, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.myBeatsTableView.allowsSelection = true
                })
            }
        }
        
    }
    
    @IBOutlet weak var myBeatsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myBeatsTableView.delegate = self
        myBeatsTableView.dataSource = self
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func loadBeats() {
        view.addSubview(activityView)
        LBUser.getBeats(username: UserDefaults.standard.string(forKey: "username")!, token: keychain.get("token")!) { (beats, error) in
            if error == nil {
                self.myBeatsTitles = beats as! [String]
                self.activityView.removeFromSuperview()
                self.myBeatsTableView.reloadData()
            }
            else {
                let alert = UIAlertController(title: "Failure", message: "Unable to load beats", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                })
            }
        }
    }
}
