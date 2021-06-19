//
//  CreateUserViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 14/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateUserViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButtonOutlet: UIButton!
    
    var auth: Auth!
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Firebase Configuration
        auth = Auth.auth()
        firestore = Firestore.firestore()
        
        // Adding redius to the button corner
        createAccountButtonOutlet.layer.cornerRadius = 25
        createAccountButtonOutlet.clipsToBounds = true
    }
    
    
    @IBAction func createAccountButton(_ sender: Any) {
        self.createAccount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func createAccount() {
        if let name = nameTextField.text {
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
                    if let confirmPassoword = confirmPasswordTextField.text {
                        
                        if password == confirmPassoword {
                            
                            auth.createUser(withEmail: email, password: password) { (resultData, error) in
                                
                                if error == nil {
                                    
                                    // Save user data on firebase firestore with name
                                    if let userId = resultData?.user.uid {
                                        self.firestore.collection("users")
                                        .document(userId)
                                        .setData([
                                            "name": name,
                                            "email": email,
                                            "id": userId
                                        ])
                                    }
                                    
                                    self.performSegue(withIdentifier: "signUpSegue", sender: nil)
                                    
                                } else {
                                    self.displayMessage(title: "Fail!", message: "Failed to create your account. Try again!")
                                }
                                
                            }
                            
                        } else { // password and confirm password do not match
                            self.displayMessage(title: "Error", message: "Password and Confirm Password don't match")
                        }
                    } else {
                        self.displayMessage(title: "Error", message: "Type confirm password!")
                    }
                } else {
                    self.displayMessage(title: "Error", message: "Type your password!")
                }
            } else {
                self.displayMessage(title: "Error", message: "Type your email!")
            }
        } else {
            self.displayMessage(title: "Error", message: "Type your name!")
        }
    }
    
    
    func displayMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }

}
