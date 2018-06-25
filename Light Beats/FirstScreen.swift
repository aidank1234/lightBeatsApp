//
//  FirstScreen.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/30/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit
import AVFoundation

class FirstScreen: UIViewController {
    let keychain = KeychainSwift()
    var token: String = ""
    var tokenLong: String = ""
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    @IBOutlet weak var lightBeatsLogo: UIImageView!
    @IBAction func joinSessionPressed(_ sender: Any) {
        joinSessionButton.isEnabled = false
        hostLightBeatButton.isEnabled = false
        createLightBeatButton.isEnabled = false
        view.addSubview(activityView)
        
        if keychain.get("token") == nil || keychain.get("tokenLong") == nil {
            UserDefaults.standard.removeObject(forKey: "username")
            LBUser.getShortTokens(token: keychain.get("token")!, tokenLong: keychain.get("tokenLong")!) { (tokens, error) in
                if error == nil {
                    self.activityView.removeFromSuperview()
                    self.token = tokens![0]
                    self.tokenLong = tokens![1]
                    let keychain = KeychainSwift()
                    keychain.set(self.token, forKey: "token")
                    keychain.set(self.tokenLong, forKey: "tokenLong")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "joinSession")
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: {
                        self.activityView.removeFromSuperview()
                        self.joinSessionButton.isEnabled = true
                        self.hostLightBeatButton.isEnabled = true
                        self.createLightBeatButton.isEnabled = true
                    })
                }
            }
        }
        else {
            UserDefaults.standard.removeObject(forKey: "username")
            LBUser.getShortTokens(token: "", tokenLong: "") { (tokens, error) in
                if error == nil {
                    self.activityView.removeFromSuperview()
                    self.token = tokens![0]
                    self.tokenLong = tokens![1]
                    let keychain = KeychainSwift()
                    keychain.set(self.token, forKey: "token")
                    keychain.set(self.tokenLong, forKey: "tokenLong")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "joinSession")
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: {
                        self.activityView.removeFromSuperview()
                        self.joinSessionButton.isEnabled = true
                        self.hostLightBeatButton.isEnabled = true
                        self.createLightBeatButton.isEnabled = true
                    })
                }
            }
        }
    }
    @IBOutlet weak var joinSessionButton: UIButton!
    @IBOutlet weak var hostLightBeatButton: UIButton!
    @IBOutlet weak var createLightBeatButton: UIButton!
    @IBAction func hostLightBeat(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "username") == nil || keychain.get("token") == nil || keychain.get("tokenLong") == nil {
            UserDefaults.standard.set("beatSelector", forKey: "nextID")
            UserDefaults.standard.synchronize()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "logInSignUp")
            self.present(controller, animated: true, completion: nil)
        }
        else {
            joinSessionButton.isEnabled = false
            hostLightBeatButton.isEnabled = false
            createLightBeatButton.isEnabled = false
            view.addSubview(activityView)
            LBUser.checkSession(username: UserDefaults.standard.string(forKey: "username")!, token: keychain.get("token")!, tokenLong: keychain.get("tokenLong")!) { (tokens, error) in
                if error == nil {
                    self.activityView.removeFromSuperview()
                    self.token = tokens![0]
                    self.tokenLong = tokens![1]
                    let keychain = KeychainSwift()
                    keychain.set(self.token, forKey: "token")
                    keychain.set(self.tokenLong, forKey: "tokenLong")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "beatSelector")
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    self.keychain.clear()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "logInSignUp")
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func createLightBeatPressed(_ sender: Any) {
        if UserDefaults.standard.string(forKey: "username") == nil || keychain.get("token") == nil || keychain.get("tokenLong") == nil {
            UserDefaults.standard.set("beatWorkshop", forKey: "nextID")
            UserDefaults.standard.synchronize()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "logInSignUp")
            self.present(controller, animated: true, completion: nil)
        }
        else {
            joinSessionButton.isEnabled = false
            hostLightBeatButton.isEnabled = false
            createLightBeatButton.isEnabled = false
            view.addSubview(activityView)
            LBUser.checkSession(username: UserDefaults.standard.string(forKey: "username")!, token: keychain.get("token")!, tokenLong: keychain.get("tokenLong")!) { (tokens, error) in
                if error == nil {
                    self.activityView.removeFromSuperview()
                    self.token = tokens![0]
                    self.tokenLong = tokens![1]
                    let keychain = KeychainSwift()
                    keychain.set(self.token, forKey: "token")
                    keychain.set(self.tokenLong, forKey: "tokenLong")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "beatWorkshop")
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    self.keychain.clear()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "logInSignUp")
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleTorch(on: false)
        lightBeatsLogo.layer.masksToBounds = true
        lightBeatsLogo.layer.cornerRadius = 10.0
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "shouldDeleteSession") {
            LBSession.deleteSession(code: UserDefaults.standard.integer(forKey: "sessionCode"), token: keychain.get("token")!) { (response, error) in
                if response == 200 && error == nil {
                    UserDefaults.standard.set(false, forKey: "shouldDeleteSession")
                    UserDefaults.standard.synchronize()
                }
                else {
                    print("Problem deleting session")
                }
            }
        }
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

}
