//
//  HostBeat.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/4/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class HostBeat: UIViewController {
    @IBOutlet weak var beatNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var playsLabel: UILabel!
    @IBOutlet weak var ratingStars: CosmosView!
    @IBOutlet weak var songStartTimeLabel: UILabel!
    @IBOutlet weak var beatLengthLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var hostBeatButton: UIButton!
    @IBAction func hostBeatPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "session")
        self.present(controller, animated: true, completion: nil)
    }
    @IBAction func backButtonPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beatNameLabel.text = Globals.beatNameDownload
        if Globals.songRelationDownload == false {
            songNameLabel.text = "Song Name: No Song Relation"
            songArtistLabel.text = "Song Artist: No Song Relation"
        }
        else {
            songNameLabel.text = "Song Name: \(Globals.songRelationNameDownload)"
            songArtistLabel.text = "Song Artist: \(Globals.songRelationArtistDownload)"
        }
        playsLabel.text = "Plays: \(Globals.playsDownload)"
        if Globals.ratingDownload <= 0 {
            ratingStars.rating = 0
        }
        else {
            ratingStars.rating = Globals.ratingDownload
        }
        songStartTimeLabel.text = "Song Start Time: \(Globals.songStartTimeDownload) seconds"
        var totalBeatLength = 0.00
        for length in Globals.beatLengthsDownload {
            totalBeatLength = totalBeatLength + length
        }
        beatLengthLabel.text = "Beat Length: \(round(totalBeatLength)) seconds"
        createdByLabel.text = "Created By: \(Globals.createdByDownload)"
        

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
