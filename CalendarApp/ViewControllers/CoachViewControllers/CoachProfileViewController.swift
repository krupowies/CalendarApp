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
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentUsername()
    }
    
    func setCurrentUsername(){
           let currentUserID = Auth.auth().currentUser?.uid
           db.collection(K.FStore.usersCollection)
               .whereField("ID", isEqualTo: currentUserID as Any)
               .getDocuments { (querySnapshot, error) in
                   if let e = error {
                       print("Problem with getting athlete data : \(e)")
                   } else {
                       if let snapshotDocuments = querySnapshot?.documents {
                           for doc in snapshotDocuments {
                               let username = doc.get("username")
                               self.usernameLabel.text = (username as! String)
                           }
                       }
                   }
           }
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
