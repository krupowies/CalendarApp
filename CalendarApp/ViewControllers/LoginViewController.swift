//
//  LoginViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 05/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextFileds()
        setUpButtons()
    }
    
    func setUpTextFileds() {
        emailTextField.layer.cornerRadius = 0.5
           passwordTextField.layer.cornerRadius = 0.5
       }
    
    func setUpButtons() {
        loginButton.layer.cornerRadius = 10
    }
    
    func choosePanel(role: String) {
        ////ADD CONSTANT FILE FOR ALL Identifier STRINGS LATER !!!
        if role == "coach" {
            performSegue(withIdentifier: "CoachSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "AthleteSegue", sender: nil)
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{Auth.auth().signIn(withEmail: email, password: password) { authResult, error in if let e = error {
            print(e)
        } else {
            //ADD CONSTANT FILE FOR ALL DATABASE STRINGS LATER !!!
            let userID = Auth.auth().currentUser?.uid
            
            self.db.collection("users").whereField("ID", isEqualTo: userID ?? "ROLE ERROR")
                .getDocuments { (querySnapshot, err) in
                    if let error = err {
                        print("Error while getting value \(error)")
                    } else {
                        for document in querySnapshot!.documents{
                            print(document.get("username") ?? "username error")
                            let currentRole = document.get("role") ?? "role error"
                            print(currentRole)
                            self.choosePanel(role: currentRole as! String)
                        }
                    }
            }
            }
            }
        }
    }
}
