//
//  ChatsViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 15/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChatsViewController: UIViewController {

    var auth: Auth!
    var handler: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        
        // Checks if user is logged or not (used to redirect the user to the login screen if it is not logged):
        handler = auth.addStateDidChangeListener { (authentication, user) in
            
            if user == nil {
                self.performSegue(withIdentifier: "automaticLoginSegue", sender: nil)
            }
            
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        auth.removeStateDidChangeListener(handler)
    }

}
