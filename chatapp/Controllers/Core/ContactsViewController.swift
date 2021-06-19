//
//  ContactsViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 15/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseFirestore

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var contactsSearchBar: UISearchBar!
    @IBOutlet weak var contactsTableView: UITableView!
    
    var auth: Auth!
    var db: Firestore!
    var loggedUserId: String!
    var contactsList: [Dictionary<String, Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsSearchBar.delegate = self
        contactsTableView.separatorStyle = .none
        
        auth = Auth.auth()
        db = Firestore.firestore()
        
        // Retrieve logged user id:
        if let id = auth.currentUser?.uid {
            self.loggedUserId = id
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveContacts()
    }
    
    // Search when user types some letter in the search bar:
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When user finishes the searching, all the contacts should appear again:
        if searchText == "" {
            retrieveContacts()
        }
    }
    
    
    //This method searches only when the user clicks on the searh button:
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let textResult = searchBar.text {
            if textResult != "" {
                searchContacts(text: textResult)
            }
        }
    }
    
    func searchContacts(text: String) {
        
        let filterList: [Dictionary<String, Any>] = self.contactsList
        self.contactsList.removeAll()
        
        for item in filterList {
            if let name = item["name"] as? String {
                if name.lowercased().contains(text.lowercased()) {
                    self.contactsList.append(item)
                }
            }
        }
        
        self.contactsTableView.reloadData()
        
    }
    
    
    func retrieveContacts() {
        
        self.contactsList.removeAll()
        db.collection("users")
        .document(loggedUserId)
        .collection("contacts")
            .getDocuments { (snapshotResult, error) in
                
                if let snapshot = snapshotResult {
                    for document in snapshot.documents {
                        
                        let contactData = document.data()
                        self.contactsList.append(contactData)
                        
                    }
                    self.contactsTableView.reloadData()
                }
                
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let totalContacts = self.contactsList.count
        
        if totalContacts == 0 {
            return 1
        }
        return totalContacts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsCell", for: indexPath) as! ContactTableViewCell
        
        cell.profilePicture.isHidden = false
        if self.contactsList.count == 0 {
            cell.contactName.text = "No contact added."
            cell.contactEmail.text = ""
            cell.profilePicture.isHidden = true
            return cell
        }
        
        let contactData = self.contactsList[indexPath.row]
        
        cell.contactName.text = contactData["name"] as? String
        cell.contactEmail.text = contactData["email"] as? String
        
        if let photo = contactData["imageURL"] as? String {
            cell.profilePicture.sd_setImage(with: URL(string: photo), completed: nil)
        } else {
            cell.profilePicture.image = UIImage(named: "standard-user-picture")
        }
        
        return cell
        
    }
    
    // Used to open the message screen when clicking on a user:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.contactsTableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        let contact = self.contactsList[index]
        
        self.performSegue(withIdentifier: "initChatWithContact", sender: nil)
        
    }

}
