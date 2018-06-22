//
//  Sign Up.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/8/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class Sign_Up: UIViewController {
    let keychain = KeychainSwift()
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var token: String = ""
    var tokenLong: String = ""
    
    func validateEmail(enteredEmail:String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signUpPressed(_ sender: Any) {
        view.addSubview(activityView)
        usernameField.isUserInteractionEnabled = false
        passwordField.isUserInteractionEnabled = false
        emailField.isUserInteractionEnabled = false
        signUpButton.isEnabled = false
        
        if usernameField.text == "" || passwordField.text == "" || emailField.text == "" {
            let alert = UIAlertController(title: "Failure", message: "Please ensure you fill each field", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {
                self.activityView.removeFromSuperview()
                self.usernameField.isUserInteractionEnabled = true
                self.passwordField.isUserInteractionEnabled = true
                self.emailField.isUserInteractionEnabled = true
                self.signUpButton.isEnabled = true
            })
        }
        else if validateEmail(enteredEmail: emailField.text!) == false {
            let alert = UIAlertController(title: "Failure", message: "Please ensure the entered email is valid", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {
                self.activityView.removeFromSuperview()
                self.usernameField.isUserInteractionEnabled = true
                self.passwordField.isUserInteractionEnabled = true
                self.emailField.isUserInteractionEnabled = true
                self.signUpButton.isEnabled = true
            })
        }
        else if passwordField.text!.count < 8 {
            let alert = UIAlertController(title: "Failure", message: "Please ensure the entered password is at least 8 characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {
                self.activityView.removeFromSuperview()
                self.usernameField.isUserInteractionEnabled = true
                self.passwordField.isUserInteractionEnabled = true
                self.emailField.isUserInteractionEnabled = true
                self.signUpButton.isEnabled = true
            })
        }
        else {
            LBUser.validateUsername(username: usernameField.text!) { (response, error) in
                if error == nil {
                    if response == 200 {
                        LBUser.createUser(username: self.usernameField.text!, password: self.passwordField.text!, email: self.emailField.text!, completionHandler: { (tokens, error) in
                            if error == nil {
                                self.activityView.removeFromSuperview()
                                self.token = tokens![0]
                                self.tokenLong = tokens![1]
                                let keychain = KeychainSwift()
                                keychain.set(self.token, forKey: "token")
                                keychain.set(self.tokenLong, forKey: "tokenLong")
                                UserDefaults.standard.set(self.usernameField.text, forKey: "username")
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: UserDefaults.standard.string(forKey: "nextID")!)
                                self.present(controller, animated: true, completion: nil)
                            }
                            else {
                                let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: {
                                    self.activityView.removeFromSuperview()
                                    self.usernameField.isUserInteractionEnabled = true
                                    self.passwordField.isUserInteractionEnabled = true
                                    self.emailField.isUserInteractionEnabled = true
                                    self.signUpButton.isEnabled = true
                                })
                            }
                        })
                    }
                    else {
                        let alert = UIAlertController(title: "Failure", message: "The requested username is already taken", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: {
                            self.activityView.removeFromSuperview()
                            self.usernameField.isUserInteractionEnabled = true
                            self.passwordField.isUserInteractionEnabled = true
                            self.emailField.isUserInteractionEnabled = true
                            self.signUpButton.isEnabled = true
                        })
                    }
                }
                else {
                    let alert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: {
                        self.activityView.removeFromSuperview()
                        self.usernameField.isUserInteractionEnabled = true
                        self.passwordField.isUserInteractionEnabled = true
                        self.emailField.isUserInteractionEnabled = true
                        self.signUpButton.isEnabled = true
                    })
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
