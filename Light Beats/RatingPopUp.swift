//
//  RatingPopUp.swift
//  Light Beats
//
//  Created by Aidan Kaiser on 6/22/18.
//  Copyright © 2018 Aidan Kaiser. All rights reserved.
//

import UIKit

protocol PopupProtocol {
    func dismiss()
}


class RatingPopUp: UIViewController {
    let keychain = KeychainSwift()
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var delegate: PopupProtocol?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func donePressed(_ sender: Any) {
        doneButton.isEnabled = false
        view.addSubview(activityView)
        if rating.rating != 0 {
            LBBeat.updateRating(name: Globals.beatNameDownload, rating: rating.rating, token: keychain.get("token")!) { (response, error) in
                self.delegate?.dismiss()
            }
            
        }
    }
    @IBOutlet weak var rating: CosmosView!
    
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
