//
//  logIn.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/23/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class logIn: UIViewController {
    @IBOutlet weak var logInButton: UIButton!
    var token: String = ""
    var tokenLong: String = ""
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
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
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func logIn(_ sender: Any) {
        logInButton.isEnabled = false
        view.addSubview(activityView)
        if usernameField.text! == "" || passwordField.text! == "" {
            let alert = UIAlertController(title: "Failure", message: "Please ensure a username and password are entered", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {
                self.activityView.removeFromSuperview()
                self.logInButton.isEnabled = true
            })
        }
        else {
            LBUser.logIn(username: usernameField.text!, password: passwordField.text!) { (tokens, error) in
                if error == nil {
                    self.activityView.removeFromSuperview()
                    self.token = tokens![0]
                    self.tokenLong = tokens![1]
                    let keychain = KeychainSwift()
                    keychain.set(self.token, forKey: "token")
                    keychain.set(self.tokenLong, forKey: "tokenLong")
                    UserDefaults.standard.set(self.usernameField.text, forKey: "username")
                    UserDefaults.standard.synchronize()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: UserDefaults.standard.string(forKey: "nextID")!)
                    self.present(controller, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Failure", message: "Please enter a valid username and password", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: {
                    self.activityView.removeFromSuperview()
                    self.logInButton.isEnabled = true
                })
                }
            }
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
