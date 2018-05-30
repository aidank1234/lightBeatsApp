//
//  BeatPlayer.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/23/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import AVFoundation

class BeatPlayer: UIViewController {
    var beatLengths: [Double]?
    var beatStart = -1
    var brightness: [Double]?
    var startTime: TimeInterval?
    var torchOn = false
    let keychain = KeychainSwift()
    var currentBrightness = 0.0
    var brightnessCounter = 1
    var totalBrightness = 0.0
    
    var brightnessTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var beatNameField: UITextField!
    
    @IBAction func downloadBeat(_ sender: Any) {
        LBBeat.beatByName(name: beatNameField.text!, token: keychain.get("token")!) { (beat, error) in
            self.beatLengths = beat?.beatLengths
            self.beatStart = (beat?.beatStart)!
            self.brightness = (beat?.brightness)!
        }
        
    }

    @objc func changeCurrentBrightness() {
        currentBrightness = brightness![brightnessCounter]
        print(currentBrightness)
        if(brightnessCounter != (brightness?.count)! - 1) {
            brightnessCounter = brightnessCounter + 1
        }
    }
    
    @IBAction func playBeat(_ sender: Any) {
        currentBrightness = brightness![0]
        startTime = Date.timeIntervalSinceReferenceDate
        if beatStart == 1 {
            toggleTorch(on: true)
            torchOn = true
        }
        else {
            toggleTorch(on: false)
            torchOn = false
        }
        brightnessTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(changeCurrentBrightness), userInfo: nil, repeats: true)
        
        DispatchQueue.global(qos: .background).async {
        for length in self.beatLengths! {
            while Date.timeIntervalSinceReferenceDate - self.startTime! < length {
            }
            
            if self.torchOn == true {
                self.toggleTorch(on: false)
                self.torchOn = false
            }
            else {
                self.toggleTorch(on: true)
                self.torchOn = true
            }
            self.startTime = Date.timeIntervalSinceReferenceDate
        }
        }
        
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    try! device.setTorchModeOn(level: Float(currentBrightness))
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
