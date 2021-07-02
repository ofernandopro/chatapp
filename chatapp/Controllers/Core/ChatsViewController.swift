//
//  ChatsViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 15/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseAuth
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewChats: UITableView!
    var listChats: [Dictionary<String, Any>] = []
    var chatsListener: ListenerRegistration!
    
    var auth: Auth!
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewChats.separatorStyle = .none
        
        auth = Auth.auth()
        db = Firestore.firestore()

    }
    
    func addListenerGetMessages() {
        if let idLoggedUser = auth.currentUser?.uid {
            chatsListener = db.collection("chats")
            .document(idLoggedUser)
            .collection("last_chat")
                .addSnapshotListener { (querSnapshot, error) in
                    
                    if error == nil {
                        
                        self.listChats.removeAll()
                        
                        if let snapshot = querSnapshot {
                            for document in snapshot.documents {
                                let data = document.data()
                                self.listChats.append(data)
                            }
                            self.tableViewChats.reloadData()
                        }
                    }
                    
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        
        let data = self.listChats[indexPath.row]
        let nameContact = data["userName"] as? String
        let lastMessage = data["lastMessage"] as? String
        
        
        cell.nameContactLabel.text = nameContact
        cell.lastMessageLabel.text = lastMessage
        
        if let urlUserPhoto = data["userPhotoURL"] as? String {
            cell.profilePhoto.sd_setImage(with: URL(string: urlUserPhoto), completed: nil)
        } else {
            cell.profilePhoto.image = UIImage(named: "standard-user-picture")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableViewChats.deselectRow(at: indexPath, animated: true)
        
        let chat = self.listChats[indexPath.row]
        
        if let id = chat["idRecipient"] as? String {
            if let name = chat["userName"] as? String {
                if let url = chat["userPhotoURL"] as? String {
                    
                    let contact: Dictionary<String, Any> = [
                        "id": id,
                        "name": name,
                        "imageURL": url
                    ]
                    
                    self.performSegue(withIdentifier: "initChatSegue", sender: contact)
                    
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "initChatSegue" {
            let destinyView = segue.destination as! MessagesViewController
            destinyView.contact = sender as? Dictionary
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addListenerGetMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        chatsListener.remove()
    }

}
