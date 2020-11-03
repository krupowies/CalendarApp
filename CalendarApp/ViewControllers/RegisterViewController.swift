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
    
    
    @IBAction func registerTapped(_ sender: Any) {
        //Validate textfields. If everything is OK -> crate user. If not -> show error
        let error = validateTextFields()
        if error != nil {
            print(error!)
        }
    }
}
