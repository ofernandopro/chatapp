//
//  LoginViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 14/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    var auth: Auth!
    var handler: AuthStateDidChangeListenerHandle!
    
    @IBAction func signUpButton(_ sender: Any) {
        self.performSegue(withIdentifier: "loginToSignUpSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
                
        self.checkIfLogged()
        
        loginButtonOutlet.layer.cornerRadius = 25
        loginButtonOutlet.clipsToBounds = true
        
    }
    
    // Check if user is logged or not (used to redirect the user to the login screen if it is not logged):
    func checkIfLogged() {
        handler = auth.addStateDidChangeListener { (authentication, user) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    @IBAction func loginButton(_ sender: Any) {
        self.logIn()
    }
    
    func logIn() {
        if let email = email.text {
            if let password = password.text {
                
                auth.signIn(withEmail: email, password: password) { (user, error) in
                    
                    if error == nil {
                        
                        if user != nil {
                            self.performSegue(withIdentifier: "loginSegue", sender: nil)
                        }
                        
                    } else {
                        self.displayMessage(title: "Error", message: "Error to log in. Try again!")
                    }
                }
            } else {
                self.displayMessage(title: "Error", message: "Type your password!")
            }
        } else {
            self.displayMessage(title: "Error", message: "Type your email!")
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        auth.removeStateDidChangeListener(handler)
    }
    
}
