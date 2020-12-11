//
//  CoachProfileViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 08/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class CoachProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func logOutButtonTap(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "logOutSegue", sender: nil)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    
}
