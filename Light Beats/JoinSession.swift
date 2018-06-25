//
//  JoinSession.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/4/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import AVFoundation

class JoinSession: UIViewController, UITextFieldDelegate, PopupProtocol {
    func dismiss() {
        self.dismissPopup(completion: nil)
        
        UserDefaults.standard.set(false, forKey: "needsToRate")
        UserDefaults.standard.synchronize()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "firstScreen")
        self.present(controller, animated: true, completion: nil)
    }
    
    
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
    var requestTimer: Timer?
    var makeTimer = true
    
    var popupVC: RatingPopUp?
    

    
    @IBOutlet weak var enterSessionCodeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var lightBeatsLogo: UIImageView!
    @IBOutlet weak var sessionCodeField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startButtonPressed(_ sender: Any) {
        if sessionCodeField.text != "" {
        view.addSubview(activityView)
        startButton.isEnabled = false
        sessionCodeField.isUserInteractionEnabled = false
        LBSession.joinSession(code: Int(sessionCodeField.text!)!, token: keychain.get("token")!) { (beat, error) in
            if error == nil {
                self.beatLengths = beat?.beatLengths
                self.beatStart = (beat?.beatStart)!
                self.brightness = (beat?.brightness)!
                Globals.beatNameDownload = (beat?.name)!
                self.startButton.backgroundColor = UIColor.gray
                self.startButton.setTitle("Waiting", for: UIControlState.normal)
                self.checkSessionRecursive()
            }
            else {
                let alert = UIAlertController(title: "Failure", message: "Please ensure the session code is valid", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.startButton.isEnabled = true
                    self.sessionCodeField.isUserInteractionEnabled = true
                })
            }
        }
        }
    }
    
    var toRemove: [Int] = []
    var toRemoveBrightness: [Int] = []
    func checkSessionRecursive() {
        LBSession.checkLive(code: Int(sessionCodeField.text!)!, token: keychain.get("token")!) { (dateLive, error) in
            if error == nil {
                if dateLive != -1 {
                    self.requestTimer?.invalidate()
                    self.activityView.removeFromSuperview()
                    self.backButton.removeFromSuperview()
                    self.sessionCodeField.removeFromSuperview()
                    self.startButton.removeFromSuperview()
                    self.enterSessionCodeLabel.removeFromSuperview()
                    self.lightBeatsLogo.isHidden = false
                    let nowTime = Date.timeIntervalBetween1970AndReferenceDate + Date.timeIntervalSinceReferenceDate
                    var elapsedTime = nowTime - Double(dateLive!)
                    print(elapsedTime)
                    let amountToRemove = elapsedTime / 0.02
                    
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
                        if number - countRemovedBrightness < (self.brightness?.count)! {
                            self.brightness?.remove(at: number - countRemovedBrightness)
                            countRemovedBrightness = countRemovedBrightness - 1
                        }
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
                    
                    

                    
                        var totalLength = 0.0
                        for length in self.beatLengths! {
                            totalLength = totalLength + length
                        }
                    
                    var ratingTimer = Timer.scheduledTimer(timeInterval: totalLength, target: self, selector: #selector(self.showRating), userInfo: nil, repeats: false)
                    
                    
                    self.startDisplayLink()
                    
                        DispatchQueue.global(qos: .background).async {
                            for length in self.beatLengths! {
                                currentLength = length
                                self.dealWithTimer(length: currentLength)
                            }
                    }
                    
                    
                    
                }
                else {
                    if self.makeTimer {
                        self.requestTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.makeRequest), userInfo: nil, repeats: true)
                        self.makeTimer = false
                    }
                }
            }
        }
    }
    
    @objc func makeRequest() {
        self.checkSessionRecursive()
    }
    @objc func showRating(timer: Timer) {
        stopDisplayLink()
        self.view.backgroundColor = UIColor.white
        UserDefaults.standard.set(true, forKey: "needsToRate")
        UserDefaults.standard.synchronize()
        showRatingPopUp()
        presentPopup(controller: popupVC!, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupVC = setPopupVC(storyboradID: "Main", viewControllerID: "ratingPopUp") as? RatingPopUp
        
        
        
        lightBeatsLogo.isHidden = true
        lightBeatsLogo.layer.masksToBounds = true
        lightBeatsLogo.layer.cornerRadius = 10.0
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
        sessionCodeField.delegate = self
        sessionCodeField.keyboardType = UIKeyboardType.numberPad
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func showRatingPopUp() {
        popupVC?.popupAlign = .center
        popupVC?.popupAnimation = .bottom
        popupVC?.delegate = self
        popupVC?.popupSize = CGSize(width: view.frame.width - 40, height: 400)
        popupVC?.touchDismiss = false
        popupVC?.popupCorner = 5.0
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
        
        self.time = time + elapsed
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
