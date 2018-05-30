//
//  logIn.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 5/23/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class logIn: UIViewController {
    var token: String = ""
    var tokenLong: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func logIn(_ sender: Any) {
        LBUser.logIn(username: usernameField.text!, password: passwordField.text!) { (tokens, error) in
            if error == nil {
                self.token = tokens![0]
                self.tokenLong = tokens![1]
                let keychain = KeychainSwift()
                keychain.set(self.token, forKey: "token")
                keychain.set(self.tokenLong, forKey: "tokenLong")
                UserDefaults.standard.set(self.usernameField.text, forKey: "username")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "beatWorkshop")
                self.present(controller, animated: true, completion: nil)
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
