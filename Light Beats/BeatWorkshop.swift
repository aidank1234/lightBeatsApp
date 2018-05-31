//
//  BeatWorkshop.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/25/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import AVFoundation

extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}

class BeatWorkshop: UIViewController {
    var beatStart: Int = -1
    var strobeMode = false
    var beatLengths: [Double] = []
    var recording = false
    var timeElapsed = 0.00
    var countdownTimer: Timer?
    var strobeDisabled = false
    var lightDisabled = false
    var afterFirstRecord = false
    var withAudio = false
    var torchActive = false
    var brightnessTimer: Timer?
    var brightnessArray: [Double] = []
    
    var lightEnd = false
    var primaryTime = 0.0
    var finalTime = 0.0
    
    var offTime = 0.0

    @IBOutlet weak var strobeButton: UIButton!
    @IBAction func strobePressed(_ sender: Any) {
        if strobeDisabled == false {
        if strobeMode == false {
            if recording == true {
                if offTime > 0.0 {
                    beatLengths.append(offTime)
                    offTime = 0.0
                }
            }
            strobeMode = true
            strobeButton.backgroundColor = UIColor.gray
            lightButton.backgroundColor = UIColorFromRGB(rgbValue: 0xC62828)
            DispatchQueue.global(qos: .background).async {
                self.strobe()
            }
        }
        else {
            strobeMode = false
            strobeButton.backgroundColor = UIColorFromRGB(rgbValue: 0xC62828)
        }
        }
    }
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var strobeSpeedLabel: UILabel!
    @IBOutlet weak var strobeSpeedSlider: UISlider!
    @IBAction func strobeSpeedSliderChanged(_ sender: Any) {
    }
    @IBOutlet weak var brightnessLabel: UILabel!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBAction func brightnessSliderEditingChanged(_ sender: Any) {
        /*
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else{return}
        if device.isTorchActive == true {
            try! device.setTorchModeOn(level: brightnessSlider.value)
        }
 */
    }
    @IBAction func brightnessSliderChanged(_ sender: Any) {
    }
    @objc func valChange(slider: UISlider) {
        if strobeDisabled == true {
            toggleTorch(on: true)
            torchActive = true
        }
    }
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startPressed(_ sender: Any) {
        if afterFirstRecord == false && recording == false {
            if torchActive == true {
                beatStart = 1
            }
            else {
                beatStart = 0
            }
            brightnessTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(appendBrightness), userInfo: nil, repeats: true)
            afterFirstRecord = true
            withAudio = false
            countdown()
        }
        else if afterFirstRecord == true && recording == false {
            toggleTorch(on: false)
            Globals.beatStartUpload = beatStart
            Globals.beatLengthsUpload = beatLengths
            Globals.brightnessUpload = brightnessArray
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "beatUpload1")
            self.present(controller, animated: true, completion: nil)
        }
    }
    @objc func appendBrightness() {
        if recording == true {
            brightnessArray.append(Double(brightnessSlider.value))
        }
    }
    @IBOutlet weak var startWithAudioButton: UIButton!
    @IBAction func startWithAudioPressed(_ sender: Any) {
        if recording == false {
            if afterFirstRecord == false {
                if torchActive == true {
                    beatStart = 1
                }
                else {
                    beatStart = 0
                }
                brightnessTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(appendBrightness), userInfo: nil, repeats: true)
                afterFirstRecord = true
                withAudio = true
                try! AVAudioSession.sharedInstance().setActive(false, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
                countdown()
            }
            else {
                if withAudio == true {
                    try! AVAudioSession.sharedInstance().setActive(false, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
                    countdown()
                }
                else {
                    countdown()
                }
            }
        }
        
    }
    @IBOutlet weak var lightButton: UIButton!
    @IBAction func lightButtonTouchDown(_ sender: Any) {
        if strobeMode == true && torchActive == true {
            if recording == true {
                beatLengths.append(0.00)
            }
        }
        if lightEnd == true {
            lightEnd = false
            beatLengths.append(0.00)
        }
        
        primaryTime = Date.timeIntervalSinceReferenceDate
        toggleTorch(on: true)
        torchActive = true
        lightButton.backgroundColor = UIColor.gray
        strobeMode = false
        strobeButton.backgroundColor = UIColor.gray
        strobeDisabled = true
    }
    @IBAction func lightButtonTouchUp(_ sender: Any) {
        finalTime = Date.timeIntervalSinceReferenceDate
        if recording == true {
            var timeDifference = finalTime - primaryTime
            beatLengths.append(timeDifference)
        }
        if lightDisabled == false {
            toggleTorch(on: false)
            torchActive = false
            lightButton.backgroundColor = UIColorFromRGB(rgbValue: 0xC62828)
            strobeButton.backgroundColor = UIColorFromRGB(rgbValue: 0xC62828)
            strobeDisabled = false
            primaryTime = 0.0
            finalTime = 0.0
        }
        else {
            lightDisabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brightnessSlider.isContinuous = true
        strobeSpeedSlider.isContinuous = true
        brightnessSlider.addTarget(self, action: #selector(valChange(slider:)), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(backgoundNofification(noftification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil);
        refresh()
        // Do any additional setup after loading the view.
    }
    @objc func backgoundNofification(noftification:NSNotification){
        
        refresh();
    }
    func refresh() {
        try! AVAudioSession.sharedInstance().setActive(true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func strobe() {
        while strobeMode == true {
            var current = Date.timeIntervalSinceReferenceDate
            while Date.timeIntervalSinceReferenceDate - current < Double(0.33 - strobeSpeedSlider.value) {
                //Do Nothing
            }
            guard let device = AVCaptureDevice.default(for: AVMediaType.video)
                else{return}
            if recording == true {
                beatLengths.append(Double(0.33 - strobeSpeedSlider.value))
            }
            if device.torchMode == .on {
                toggleTorch(on: false)
                torchActive = false
            }
            else {
                toggleTorch(on: true)
                torchActive = true
            }
        }
    }
    @objc func runTimedCode() {
        startWithAudioButton.setTitle("Continue", for: UIControlState.normal)
        startButton.setTitle("End", for: UIControlState.normal)
        startWithAudioButton.backgroundColor = UIColor.gray
        startButton.backgroundColor = UIColor.gray
        timeElapsed = timeElapsed + 0.02
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        if strobeMode == false && torchActive == false {
            offTime = offTime + 0.02
        }
        if (torchActive == true)  && offTime > 0.0 && strobeMode == false {
            beatLengths.append(offTime)
            offTime = 0.0
        }
        let seconds = 10.0 - timeElapsed
        if seconds > 0 {
            timerLabel.text = "\(seconds.second).\(seconds.millisecond)"
        }
        else {
            if strobeMode == false {
                if offTime > 0.0 {
                    if offTime < 10 {
                        beatLengths.append(offTime)
                        offTime = 0.0
                    }
                }
                else {
                    finalTime = Date.timeIntervalSinceReferenceDate
                    beatLengths.append(finalTime - primaryTime)
                    lightEnd = true
                    toggleTorch(on: false)
                    torchActive = false
                    lightButton.backgroundColor = UIColorFromRGB(rgbValue: 0xC62828)
                    strobeButton.backgroundColor = UIColorFromRGB(rgbValue: 0xC62828)
                    strobeDisabled = false
                    primaryTime = 0.0
                    finalTime = 0.0
                    lightDisabled = true
                    
                }
            }
            recording = false
            strobeMode = false
            timerLabel.text = "10.00"
            strobeButton.backgroundColor = self.UIColorFromRGB(rgbValue: 0xC62828)
            startWithAudioButton.backgroundColor = self.UIColorFromRGB(rgbValue: 0xC62828)
            startButton.backgroundColor = self.UIColorFromRGB(rgbValue: 0xC62828)
            toggleTorch(on: false)
            torchActive = false
            countdownTimer?.invalidate()
            timeElapsed = 0.00
            try! AVAudioSession.sharedInstance().setActive(true)
        }
    }
    
    func countdown() {
        recording = true
        countdownTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
    }
    
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
            else {return}
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    try! device.setTorchModeOn(level: brightnessSlider.value)
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
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
