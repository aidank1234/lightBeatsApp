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
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
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
            view.addSubview(activityView)
            nextOrFinishButton.isEnabled = false
            if beatNameField.text != "" {
                LBBeat.validateName(name: beatNameField.text!, token: keychain.get("token")!) { (response, error) in
                    if error == nil {
                        if response == 200 {
                            self.activityView.removeFromSuperview()
                            self.nextOrFinishButton.isEnabled = true
                            Globals.beatNameUpload = self.beatNameField.text!
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "beatUpload2")
                            self.present(controller, animated: true, completion: nil)
                        }
                        else {
                            let alert = UIAlertController(title: "Failure", message: "The requested beat name has already been taken", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: {
                                self.activityView.removeFromSuperview()
                                self.nextOrFinishButton.isEnabled = true
                            })
                        }
                    }
                    else {
                        let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: {
                            self.activityView.removeFromSuperview()
                            self.nextOrFinishButton.isEnabled = true
                        })
                    }
                }
            }
            else {
                let alert = UIAlertController(title: "Failure", message: "Please enter a title", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true) {
                    self.activityView.removeFromSuperview()
                    self.nextOrFinishButton.isEnabled = true
                }
            }
        }
        else {
            view.addSubview(activityView)
            nextOrFinishButton.isEnabled = false
            if beatNameField.text! != "" {
                LBBeat.validateName(name: beatNameField.text!, token: keychain.get("token")!) { (response, error) in
                    if error == nil {
                        if response == 200 {
                            LBBeat.newBeat(name: self.beatNameField.text!, beatStart: Globals.beatStartUpload, beatLengths: Globals.beatLengthsUpload, brightness: Globals.brightnessUpload, songStartTime: -1, songRelation: self.songRelationSwitch.isOn, songRelationName: "", songRelationArtist: "", createdBy: UserDefaults.standard.string(forKey: "username")!, token: self.keychain.get("token")!) { (response, error) in
                                if error == nil {
                                    if response == 200 {
                                        Globals.beatNameUpload = self.beatNameField.text!
                                        self.addBeat()
                                    }
                                    else {
                                        let alert = UIAlertController(title: "Failure", message: "An error occured during the upload", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: {
                                            self.activityView.removeFromSuperview()
                                            self.nextOrFinishButton.isEnabled = true
                                        })
                                    }
                                }
                                else {
                                    let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: {
                                        self.activityView.removeFromSuperview()
                                        self.nextOrFinishButton.isEnabled = true
                                    })
                                }
                            }
                        }
                        else {
                            let alert = UIAlertController(title: "Failure", message: "The requested beat name has already been taken", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: {
                                self.activityView.removeFromSuperview()
                                self.nextOrFinishButton.isEnabled = true
                            })
                        }
                    }
                    else {
                        let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: {
                            self.activityView.removeFromSuperview()
                            self.nextOrFinishButton.isEnabled = true
                        })
                    }
                }
            }
            else {
                let alert = UIAlertController(title: "Failure", message: "Please enter a title", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true) {
                    self.activityView.removeFromSuperview()
                    self.nextOrFinishButton.isEnabled = true
                }
            }
        }
    }
    func addBeat() {
        LBUser.addBeat(username: UserDefaults.standard.string(forKey: "username")!, beatName: self.beatNameField.text!, token: self.keychain.get("token")!, completionHandler: { (resp, err) in
            if err != nil {
                let alert = UIAlertController(title: "Failure", message: err?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.nextOrFinishButton.isEnabled = true
                })
            }
            else {
                if resp == 200 {
                    self.activityView.removeFromSuperview()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "firstScreen")
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Failure", message: "An error occured during the upload", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: {
                        self.activityView.removeFromSuperview()
                        self.nextOrFinishButton.isEnabled = true
                    })
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityView.center = self.view.center
        activityView.color = UIColor.blue
        activityView.startAnimating()
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
