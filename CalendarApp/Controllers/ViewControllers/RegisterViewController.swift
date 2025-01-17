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
import FirebaseFirestoreSwift
import FirebaseFirestore

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var roleSegment: UISegmentedControl!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let db = Firestore.firestore()
    var ifUsernameTaken = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        setUpTextFileds()
        usernameTextField.delegate = self
    }
    
    func setUpTextFileds() {
        usernameTextField.layer.cornerRadius = 0.5
        emailTextField.layer.cornerRadius = 0.5
        passwordTextField.layer.cornerRadius = 0.5
       }
    
    func setUpButtons() {
        registerButton.layer.cornerRadius = 10
    }
            
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.errorLabel.text = ""
        self.registerButton.isEnabled = true
        if textField == usernameTextField {
            self.usernameTaken { (ifTaken) in
                self.ifUsernameTaken = ifTaken
                DispatchQueue.main.async {
                    if self.ifUsernameTaken == true {
                        self.registerButton.isEnabled = false
                        self.errorLabel.text = "This username is already taken."
                    }
                }
            }
        }
    }
    
    func usernameTaken(callback: @escaping (Bool) -> Void) {
        let currentUsername = usernameTextField.text
        var isTaken = false
        self.db.collection((K.FStore.usersCollection)).whereField(K.FStore.usernameField, isEqualTo: currentUsername!)
            .getDocuments { (querySnapshot, error) in
                if let e = error {
                    print("Problem with username function : \(e)")
                } else {
                    if querySnapshot!.isEmpty {
                        isTaken = false
                        callback(isTaken)
                    } else {
                        isTaken = true
                        callback(isTaken)
                    }
                }
        }
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
            errorLabel.text = error
        } else {
            let role = setUserRole()
            if let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text {
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let e = error {
                        print(e)
                        self.errorLabel.textColor = .red
                        self.errorLabel.text = e.localizedDescription
                    } else {
                        if role == "athlete" {
                            let newUser = Athlete(email: email, username: username, role: role, ID: (result?.user.uid)!, myCoaches: [])
                            do {
                                try self.db.collection(K.FStore.usersCollection).document((result?.user.uid)!).setData(from: newUser)
                                self.errorLabel.textColor = .green
                                self.errorLabel.text = "New account successfully created"
                            } catch let error {
                                print("Error writing athlete to Firestore: \(error)")
                                self.errorLabel.text = "Error writing athlete to Firestore: \(error)"
                            }
                        } else {
                            let newUser = Coach(email: email, username: username, role: role, ID: (result?.user.uid)!, myAthletes: [])
                            do {
                                try self.db.collection(K.FStore.usersCollection).document((result?.user.uid)!).setData(from: newUser)
                                self.errorLabel.textColor = .green
                                self.errorLabel.text = "New account successfully created"
                                print("New user created")
                            } catch let error {
                                print("Error writing coach to Firestore: \(error)")
                                self.errorLabel.text = "Error writing coach to Firestore: \(error)"
                            }
                        }
                    }
                }
            }
        }
    }
}
