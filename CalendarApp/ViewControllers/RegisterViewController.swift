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

class RegisterViewController: UIViewController {
    
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
    }
    
    func setUpTextFileds() {
        usernameTextField.layer.cornerRadius = 0.5
        emailTextField.layer.cornerRadius = 0.5
        passwordTextField.layer.cornerRadius = 0.5
       }
    
    func setUpButtons() {
        registerButton.layer.cornerRadius = 10
    }
    
//    func usernameTaken(_ completion: @escaping (_ taken: Bool?) -> Void) ->Bool? {
//        let currentUsername = usernameTextField.text
//
//        db.collection((K.FStore.usersCollection)).whereField(K.FStore.usernameField, isEqualTo: currentUsername!).getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//                completion(nil) // error; unknown if taken
//            } else {
//                if querySnapshot!.isEmpty {
//                    completion(false) // no documents; not taken
//                } else {
//                    completion(true) // at least 1 document; taken
//                }
//            }
//        }
//        return nil
//    }
    
    func usernameTaken(callback: @escaping(Bool?) -> Void) {
        let currentUsername = usernameTextField.text
        self.db.collection((K.FStore.usersCollection)).whereField(K.FStore.usernameField, isEqualTo: currentUsername!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                callback(nil) // error; unknown if taken
            } else {
                if querySnapshot!.isEmpty {
                    callback(false) // no documents; not taken
                } else {
                    callback(true) // at least 1 document; taken
                }
            }
        }
    }
    
    
//    func usernameTaken() -> Bool {
//        let currentUsername = usernameTextField.text
//        var isTaken = false
//        let group = DispatchGroup()
//
//        db.collection((K.FStore.usersCollection)).whereField(K.FStore.usernameField, isEqualTo: currentUsername!)
//        .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    for document in querySnapshot!.documents {
//                        group.enter()
//                        print("Same username ID: \(document.documentID)")
//                        print("Username used")
//                        isTaken = true
//                        group.leave()
//                    }
//                }
//        }
//        group.notify(queue: .main) {
//            print(isTaken)
//            print("Group notify")
//        }
//        print("82 : \(isTaken)")
//        return isTaken
//    }
    
    func validateTextFields() -> String? {
        var error: String? =  nil
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        } else {
            self.usernameTaken { (ifTaken) in
                self.ifUsernameTaken = ifTaken ?? false
                DispatchQueue.main.async {
                    if self.ifUsernameTaken == true {
                        error = "User name taken"
                    } else {error = nil}
                }
            }
        }
        return error
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
