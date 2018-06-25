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
    var timeElapsed = 0.00
    
    var startTime: TimeInterval?
    var time: TimeInterval = 0.0
    var torchOn = false
    var currentBrightness = 0.0
    var brightnessCounter = 1
    var totalBrightness = 0.0
    var started = false
    var brightnessTimer: Timer?
    var countdownTimer: Timer?
    var totalLength = 0.0
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if started == false {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "hostBeat")
            self.present(controller, animated: true, completion: nil)
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "firstScreen")
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var refreshSubscribersButton: UIButton!
    @IBAction func refreshSubscribersPressed(_ sender: Any) {
        view.addSubview(activityView)
        startButton.isEnabled = false
        refreshSubscribersButton.isEnabled = false
        
        
        LBSession.checkSubscribers(code: Int(sessionCodeLabel.text!)!, token: keychain.get("token")!) { (response, error) in
            if error == nil {
                let alert = UIAlertController(title: "Success", message: "\(response!) subscribers", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.startButton.isEnabled = true
                    self.refreshSubscribersButton.isEnabled = true
                })
            }
            else {
                let alert = UIAlertController(title: "Failure", message: "An error occured while checking subscribers", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.startButton.isEnabled = true
                    self.refreshSubscribersButton.isEnabled = true
                })
            }
        }
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sessionCodeStationaryLabel: UILabel!
    @IBOutlet weak var sessionCodeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        view.addSubview(activityView)
        startButton.isEnabled = false
        refreshSubscribersButton.isEnabled = false
        LBSession.startSession(code: Int(sessionCodeLabel.text!)!, token: keychain.get("token")!) { (response, error) in
            if error == nil {
                
                self.started = true
                self.sessionCodeStationaryLabel.text = "Thanks for hosting!"
                self.refreshSubscribersButton.removeFromSuperview()
                self.startButton.setTitle("Starting", for: .normal)
                self.activityView.removeFromSuperview()
                self.countdownTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
                
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
                
                
                self.startDisplayLink()
                DispatchQueue.global(qos: .background).async {
                    for length in self.beatLengths! {
                        currentLength = length
                        self.dealWithTimer(length: currentLength)
                    }
                }

            }
            else {
                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.startButton.isEnabled = true
                    self.refreshSubscribersButton.isEnabled = true
                })
            }
        }
    }
    var startNext = true
    @objc func runTimedCode() {
        timeElapsed = timeElapsed + 0.02
        let seconds = 5.0 - timeElapsed
        if seconds > 0 {
            sessionCodeLabel.text = "\(seconds.second).\(seconds.millisecond)"
        }
        if timeElapsed >= 5.0 {
            startButton.setTitle("Started", for: .normal)
            countdownTimer?.invalidate()
            if startNext == true {
                var countdownTimer2 = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.runTimedCode2), userInfo: nil, repeats: true)
                startNext = false
            }
        }
    }
    var timeElapsed2 = 0.0
    @objc func runTimedCode2() {
        timeElapsed2 = timeElapsed2 + 0.05
        let seconds = totalLength - timeElapsed2
        if seconds > 0 {
            sessionCodeLabel.text = "\(seconds.second).\(seconds.millisecond)"
        }
        if timeElapsed2 >= totalLength {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "firstScreen")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
        
        view.addSubview(activityView)
        startButton.isEnabled = false
        refreshSubscribersButton.isEnabled = false
        
        LBBeat.beatByName(name: Globals.beatNameDownload, token: keychain.get("token")!) { (beat, error) in
            if error == nil {
                self.beatLengths = beat?.beatLengths
                self.beatStart = (beat?.beatStart)!
                self.brightness = beat?.brightness
                for length in self.beatLengths! {
                    self.totalLength = self.totalLength + length
                }
                self.totalLength = self.totalLength - 5.0
                
                LBSession.newSession(lightBeat: Globals.beatNameDownload, username: UserDefaults.standard.string(forKey: "username")!, token: self.keychain.get("token")!) { (sessionCode, error) in
                    if error == nil {
                        UserDefaults.standard.set(true, forKey: "shouldDeleteSession")
                        UserDefaults.standard.set(sessionCode!, forKey: "sessionCode")
                        UserDefaults.standard.synchronize()
                        self.sessionCodeLabel.text = "\(sessionCode!)"
                        self.startButton.isEnabled = true
                        self.refreshSubscribersButton.isEnabled = true
                        self.activityView.removeFromSuperview()
                    }
                    else {
                        let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: {
                            self.activityView.removeFromSuperview()
                            self.startButton.isEnabled = true
                            self.refreshSubscribersButton.isEnabled = true
                        })
                    }
                }
                
            }
            else {
                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.startButton.isEnabled = true
                    self.refreshSubscribersButton.isEnabled = true
                })
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dealWithTimer(length: Double) {
        while time < length {
        }
        if self.torchOn == true {
            self.toggleTorch(on: false)
            self.torchOn = false
        }
        else {
            self.toggleTorch(on: true)
            self.torchOn = true
        }
        time = 0.0
        self.startTime = Date.timeIntervalSinceReferenceDate
    }
    
    @objc func changeCurrentBrightness() {
        currentBrightness = brightness![brightnessCounter]
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
    
    private var displayLink: CADisplayLink?
    private var displayStartTime = 0.0
    private let animLength = 0.04
    
    func startDisplayLink() {
        
        stopDisplayLink() // make sure to stop a previous running display link
        displayStartTime = CACurrentMediaTime() // reset start time
        
        // create displayLink & add it to the run-loop
        let displayLink = CADisplayLink(
            target: self, selector: #selector(displayLinkDidFire)
        )
        displayLink.add(to: .main, forMode: .commonModes)
        self.displayLink = displayLink
    }
    
    @objc func displayLinkDidFire(_ displayLink: CADisplayLink) {
        
        var elapsed = CACurrentMediaTime() - displayStartTime
        
        if elapsed > animLength {
            stopDisplayLink()
            elapsed = animLength // clamp the elapsed time to the anim length
        }
        
        time = time + elapsed
        startDisplayLink()
    }
    
    // invalidate display link if it's non-nil, then set to nil
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
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
