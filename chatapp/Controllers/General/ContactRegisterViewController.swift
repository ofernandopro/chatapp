//
//  ContactRegisterViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 18/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ContactRegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var idLoggedUser: String!
    var emailLoggedUser: String!
    
    var auth: Auth!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
        if let currentUser = auth.currentUser {
            self.idLoggedUser = currentUser.uid
            self.emailLoggedUser = currentUser.email
        }

    }
    
    @IBAction func registerUserButton(_ sender: Any) {
        
        self.errorMessage.isHidden = true
        
        // Check if user is adding his own email:
        if let typedEmail = emailTextField.text {
            if typedEmail == self.emailLoggedUser {
                errorMessage.isHidden = false
                errorMessage.text = "You are adding your own email!"
                return
            }
            
            // Check if user exists on Firebase:
            db.collection("users")
            .whereField("email", isEqualTo: typedEmail)
                .getDocuments { (snapshotResult, error) in
                    
                    if let totalItems = snapshotResult?.count {
                        if totalItems == 0 {
                            self.errorMessage.text = "This user is not registered."
                            self.errorMessage.isHidden = false
                            return
                        }
                    }
                    
                    // Save Contact:
                    if let snapshot = snapshotResult {
                        
                        for document in snapshot.documents {
                            let data = document.data()
                            self.saveContact(contactData: data)
                        }
                        
                    }
                    
            }
        }
        
        
    }
    
    func saveContact(contactData: Dictionary<String, Any>) {
        
        if let idContactUser = contactData["id"] {
            db.collection("users")
            .document(idLoggedUser)
            .collection("contacts")
            .document(String(describing: idContactUser))
                .setData(contactData) { (error) in
                    if error == nil {
                        self.navigationController?
                        .popViewController(animated: true)
                    }
            }
        }
        
    }
    

}
