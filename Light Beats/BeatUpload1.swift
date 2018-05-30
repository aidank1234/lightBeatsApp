//
//  BeatUpload1.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/26/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class BeatUpload1: UIViewController {
    let keychain = KeychainSwift()
    
    @IBOutlet weak var beatNameField: UITextField!
    @IBOutlet weak var songRelationSwitch: UISwitch!
    @IBAction func songRelationSwitchChanged(_ sender: Any) {
        if songRelationSwitch.isOn == false {
            nextOrFinishButton.setTitle("Finish", for: UIControlState.normal)
        }
        else {
            nextOrFinishButton.setTitle("Next", for: UIControlState.normal)
        }
    }
    @IBOutlet weak var nextOrFinishButton: UIButton!
    @IBAction func nextOrFinishPressed(_ sender: Any) {
        if songRelationSwitch.isOn {
            //Next
        }
        else {
            LBBeat.newBeat(name: beatNameField.text!, beatStart: Globals.beatStartUpload, beatLengths: Globals.beatLengthsUpload, brightness: Globals.brightnessUpload, songStartTime: -1, songRelation: songRelationSwitch.isOn, songRelationName: "", songRelationArtist: "", createdBy: UserDefaults.standard.string(forKey: "username")!, token: keychain.get("token")!) { (response, error) in
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
