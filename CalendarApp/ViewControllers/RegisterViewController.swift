//
//  RegisterViewController.swift
//  CalendarApp
//
//  Created by Wojtek Krupowies on 02/11/2020.
//  Copyright © 2020 Wojtek Krupowies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var roleSegment: UISegmentedControl!
    
    let db = Firestore.firestore()
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func validateTextFields() -> String? {
        
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    func setUserRole () -> String {
        if roleSegment.selectedSegmentIndex == 1 {
            return "coach"
        } else {return "athlete"}
    }
    
    
    @IBAction func registerTapped(_ sender: Any) {
        //Validate textfields. If everything is OK -> crate user. If not -> show error
        let error = validateTextFields()
        if error != nil {
            print(error!)
        } else {
            let role = setUserRole()
            if let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text {
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let e = error {
                        print(e)
                    } else {
                        self.db.collection("users").addDocument(data: [
                            "username": username,
                            "email": email,
                            "ID": result!.user.uid,
                            "role": role
                        ]) { (error) in
                            if let e = error {
                                print("Problem with saving data to Firestore \(e)")
                            } else {
                                 print("Data saved successfully !")
                            }
                        }
                    }
                }
            }
        }
    }
}
