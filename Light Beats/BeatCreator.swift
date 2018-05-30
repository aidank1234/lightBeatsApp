//
//  BeatCreator.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/23/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import AVFoundation

class BeatCreator: UIViewController {
    var torchSetting: Bool?
    var beatStart: Int = -1
    var beatLengths: [Double] = []
    let keychain = KeychainSwift()
    var started = false
    var startTime: TimeInterval?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        torchSetting = true
        beatStart = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func startRecording(_ sender: Any) {
        if started == false {
            if torchSetting! == false {
                beatStart = 1
            }
            started = true
            startTime = Date.timeIntervalSinceReferenceDate
        }
        else {
            /*
            let elapsedTime = Date.timeIntervalSinceReferenceDate - startTime!
            beatLengths.append(elapsedTime)
            toggleTorch(on: false)
            
            LBBeat.newBeat(name: "Aidan's First Beat", beatStart: beatStart, beatLengths: beatLengths, songRelationName: "Power", songRelationArtist: "Kanye West", createdBy: UserDefaults.standard.string(forKey: "username")!, token: keychain.get("token")!) { (response, error) in
                if error != nil {
                    print("NOT GOOD")
                    
                }
                else {
                    print("GOOD")
                }
            }
            */
        }
        
    }
    @IBAction func changeTorchState(_ sender: Any) {
        toggleTorch(on: torchSetting!)
        if torchSetting! == true {
            torchSetting = false
        }
        else {
            torchSetting = true
        }
        
        if started == true {
            let elapsedTime = Date.timeIntervalSinceReferenceDate - startTime!
            beatLengths.append(elapsedTime)
            print("appended")
            startTime = Date.timeIntervalSinceReferenceDate
        }
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
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
