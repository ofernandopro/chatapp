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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        
        loginButtonOutlet.layer.cornerRadius = 25
        loginButtonOutlet.clipsToBounds = true
        
    }
    
    @IBAction func loginButton(_ sender: Any) {
        self.logIn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    
}
