//
//  startSession.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/4/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import AVFoundation

class startSession: UIViewController {
    let keychain = KeychainSwift()
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var beatLengths: [Double]?
    var beatStart = -1
    var brightness: [Double]?
    
    var startTime: TimeInterval?
    var time: TimeInterval = 0.0
    var torchOn = false
    var currentBrightness = 0.0
    var brightnessCounter = 1
    var totalBrightness = 0.0
    
    var brightnessTimer: Timer?
    
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        view.addSubview(activityView)
        startButton.isEnabled = false
        LBSession.startSession(code: Int(sessionCodeLabel.text!)!, token: keychain.get("token")!) { (response, error) in
            if error == nil {
                self.view.backgroundColor = UIColor.green
                let alert = UIAlertController(title: "Success", message: "Session started with \(response!) subscribers", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    LBBeat.beatByName(name: Globals.beatNameDownload, token: self.keychain.get("token")!, completionHandler: { (beat, error) in
                        if error == nil {
                            self.beatLengths = beat?.beatLengths
                            self.beatStart = (beat?.beatStart)!
                            self.brightness = (beat?.brightness)!
                            self.checkSessionRecursive()
                        }
                    })
                    
                    
                    
                    
                    self.activityView.removeFromSuperview()
                })
            }
            else {
                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.startButton.isEnabled = true
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
        
        view.addSubview(activityView)
        startButton.isEnabled = false
        LBSession.newSession(lightBeat: Globals.beatNameDownload, username: UserDefaults.standard.string(forKey: "username")!, token: keychain.get("token")!) { (sessionCode, error) in
            if error == nil {
                self.sessionCodeLabel.text = "\(sessionCode!)"
                self.startButton.isEnabled = true
                self.activityView.removeFromSuperview()
            }
            else {
                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.startButton.isEnabled = true
                })
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var toRemove: [Int] = []
    var toRemoveBrightness: [Int] = []
    func checkSessionRecursive() {
        LBSession.checkLive(code: Int(sessionCodeLabel.text!)!, token: keychain.get("token")!) { (dateLive, error) in
            if error == nil {
                if dateLive != -1 {
                    self.activityView.removeFromSuperview()
                    let nowTime = Date.timeIntervalBetween1970AndReferenceDate + Date.timeIntervalSinceReferenceDate
                    var elapsedTime = nowTime - Double(dateLive!)
                    print(elapsedTime)
                    var amountToRemove = elapsedTime / 0.02
                    
                    for index in 0...(self.beatLengths?.count)! - 1 {
                        if elapsedTime > self.beatLengths![index] {
                            self.toRemove.append(index)
                            elapsedTime = elapsedTime - self.beatLengths![index]
                            
                            if self.beatStart == 1 {
                                self.beatStart = 0
                            }
                            else {
                                self.beatStart = 1
                            }
                        }
                        else if elapsedTime > 0 {
                            self.beatLengths![index] = self.beatLengths![index] - elapsedTime
                            elapsedTime = 0
                        }
                    }
                    for index in 0...Int(round(amountToRemove)) - 1 {
                        self.toRemoveBrightness.append(index)
                    }
                    var countRemoved = 0
                    for number in self.toRemove {
                        self.beatLengths?.remove(at: number - countRemoved)
                        countRemoved = countRemoved + 1
                    }
                    var countRemovedBrightness = 0
                    for number in self.toRemoveBrightness {
                        self.brightness?.remove(at: number - countRemovedBrightness)
                        countRemovedBrightness = countRemovedBrightness - 1
                    }
                    
                    self.currentBrightness = self.brightness![0]
                    self.startTime = Date.timeIntervalSinceReferenceDate
                    if self.beatStart == 1 {
                        self.toggleTorch(on: true)
                        self.torchOn = true
                    }
                    else {
                        self.toggleTorch(on: false)
                        self.torchOn = false
                    }
                    self.brightnessTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.changeCurrentBrightness), userInfo: nil, repeats: true)
                    
                    
                    var currentLength = self.beatLengths![0]
                    
                    
                    var beatLengthTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.advanceTimer), userInfo: nil, repeats: true)
                    DispatchQueue.global(qos: .background).async {
                        for length in self.beatLengths! {
                            currentLength = length
                            self.dealWithTimer(length: currentLength)
                        }
                    }
                    
                    
                    
                    
                }
                else {
                    self.checkSessionRecursive()
                }
            }
        }
    }
    
    @objc func advanceTimer(timer: Timer) {
        time = Date.timeIntervalSinceReferenceDate - self.startTime!
    }
    
    func dealWithTimer(length: Double) {
        while time < length {
        }
        if self.torchOn == true {
            DispatchQueue.main.async {
                self.view.backgroundColor = UIColor.black
            }
            self.toggleTorch(on: false)
            self.torchOn = false
        }
        else {
            DispatchQueue.main.async {
                self.view.backgroundColor = UIColor.white
            }
            self.toggleTorch(on: true)
            self.torchOn = true
        }
        time = 0.0
        self.startTime = Date.timeIntervalSinceReferenceDate
    }
    
    @objc func changeCurrentBrightness() {
        currentBrightness = brightness![brightnessCounter]
        print(currentBrightness)
        if(brightnessCounter != (brightness?.count)! - 1) {
            brightnessCounter = brightnessCounter + 1
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
