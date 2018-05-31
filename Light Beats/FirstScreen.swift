//
//  FirstScreen.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/30/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class FirstScreen: UIViewController {
    let keychain = KeychainSwift()
    var token: String = ""
    var tokenLong: String = ""
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    @IBAction func joinSessionPressed(_ sender: Any) {
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
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "logInSignUp")
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
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
