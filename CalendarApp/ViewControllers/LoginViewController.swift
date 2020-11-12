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
    @IBOutlet weak var errorLabel: UILabel!
    
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
        if role == "coach" {
            performSegue(withIdentifier: K.Segues.toCoachPanel, sender: nil)
        } else {
            performSegue(withIdentifier: K.Segues.toAthletePanel, sender: nil)
        }
    }
    
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{Auth.auth().signIn(withEmail: email, password: password) { authResult, error in if let e = error {
            print(e.localizedDescription)
            self.errorLabel.textColor = .red
            self.errorLabel.text = e.localizedDescription
        } else {
            self.errorLabel.textColor = .green
            self.errorLabel.text = "Correct email and password"
            let userID = Auth.auth().currentUser?.uid
            
            self.db.collection(K.FStore.usersCollection).whereField(K.FStore.IDField, isEqualTo: userID ?? "ROLE ERROR")
                .getDocuments { (querySnapshot, err) in
                    if let error = err {
                        print("Error while getting value \(error)")
                    } else {
                        for document in querySnapshot!.documents{
                            print(document.get(K.FStore.usernameField) ?? "username error")
                            let currentRole = document.get(K.FStore.roleField) ?? "role error"
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
