//
//  LogInSignUp.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/9/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

class LogInSignUp: UIViewController {
    @IBOutlet weak var lightBeatsLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lightBeatsLogo.layer.masksToBounds = true
        lightBeatsLogo.layer.cornerRadius = 10.0
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
