//
//  SettingsViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 15/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    var auth: Auth!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        auth = Auth.auth()
    }
    
    @IBAction func signOutButton(_ sender: Any) {
        
        do {
            try auth.signOut()
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        } catch {
            self.displayMessage(title: "Error", message: "Error to sign out! Try again.")
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
