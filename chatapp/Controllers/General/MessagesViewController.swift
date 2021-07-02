//
//  MessagesViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 18/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var message: UITextField!
    
    var listMessages: [Dictionary<String, Any>]! = []
    var idLoggedUser: String!
    var contact: Dictionary<String, Any>!
    var messagesListener: ListenerRegistration!
    var imagePicker = UIImagePickerController()
    var nameContact: String!
    var contactPhotoURL: String!
    
    var auth: Auth!
    var db: Firestore!
    var storage: Storage!
    
    var nameLoggedUser: String!
    var urlLoggedUserPhoto: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()
        db = Firestore.firestore()
        storage = Storage.storage()
        
        imagePicker.delegate = self
        
        // Retrieve logged user id
        if let id = auth.currentUser?.uid {
            self.idLoggedUser = id
            getUserLoggedData()
        }
        
        // Set screen title
        if let titleScreen = contact["name"] as? String {
            nameContact = titleScreen
            self.title = nameContact
        }
        
        // Set Contact Photo
        if let url = contact["imageURL"] as? String {
            contactPhotoURL = url
        }

        tableView.backgroundView = UIImageView(image: UIImage(named: "bg"))
        tableView.separatorStyle = .none
        
    }
    
    func getUserLoggedData() {
        
        let users = db.collection("users")
        .document(idLoggedUser)
        
        users.getDocument { (documentSnapshot, error) in
            
            if error == nil {
                if let data = documentSnapshot?.data() {
                    if let url = data["imageURL"] as? String {
                        if let name = data["name"] as? String {
                            self.urlLoggedUserPhoto = url
                            self.nameLoggedUser = name
                        }
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func selectPhotoButton(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let retrievedImage = info[
            UIImagePickerController.InfoKey
            .originalImage
        ] as! UIImage
        
        let images = storage
            .reference()
            .child("images")
        
        if let uploadImage = retrievedImage.jpegData(compressionQuality: 0.5) {
            
            let uniqueId = UUID().uuidString
            let imageName = "\(uniqueId).jpg"
            
            let messageImageRef = images.child("messages").child(imageName)
            
            messageImageRef.putData(uploadImage, metadata: nil) { (metaData, error) in
                
                if error == nil {
                    
                    messageImageRef.downloadURL { (url, error) in
                        
                        if let imageURL = url?.absoluteString {
                            
                            if let idRecipientUser = self.contact["id"] as? String {
                                
                                let messageSent: Dictionary<String, Any> = [
                                    "userId": self.idLoggedUser!,
                                    "imageURL": imageURL,
                                    "date": FieldValue.serverTimestamp()
                                ]
                                
                                // Save message to the sending user
                                self.saveMessage(idSendingUser: self.idLoggedUser, idRecipient: idRecipientUser, messageSent: messageSent as Dictionary<String, Any>)
                                
                                // Save message to the recipient user
                                self.saveMessage(idSendingUser: idRecipientUser, idRecipient: self.idLoggedUser, messageSent: messageSent as Dictionary<String, Any>)
                                
                                var chat: Dictionary<String, Any> = [
                                    "lastMessage": "📸 Image..."
                                ]
                                
                                // Save chat for sending user
                                chat["idSending"] = self.idLoggedUser!
                                chat["idRecipient"] = idRecipientUser
                                chat["userName"] = self.nameContact
                                chat["userPhotoURL"] = self.contactPhotoURL
                                self.saveChat(idSending: self.idLoggedUser, idRecipient: idRecipientUser, chat: chat)
                                
                                // Save chat for recipient user
                                chat["idSending"] = idRecipientUser
                                chat["idRecipient"] = self.idLoggedUser!
                                chat["userName"] = self.nameLoggedUser
                                chat["userPhotoURL"] = self.urlLoggedUserPhoto
                                self.saveChat(idSending: idRecipientUser, idRecipient: self.idLoggedUser, chat: chat)
                                
                                
                            }
                            
                        }
                        
                    }
                    
                } else {
                    self.displayMessage(title: "Error", message: "Error uploading image! Try again.")
                }
                
            }
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func sendMessageButton(_ sender: Any) {
        
        if let typedText = message.text {
            if !typedText.isEmpty {
                if let idRecipientUser = contact["id"] as? String {
                    
                    let messageSent: Dictionary<String, Any> = [
                        "userId": idLoggedUser!,
                        "text": typedText,
                        "date": FieldValue.serverTimestamp()
                    ]
                    
                    // Save message to the sending user
                    saveMessage(idSendingUser: idLoggedUser, idRecipient: idRecipientUser, messageSent: messageSent as Dictionary<String, Any>)
                    
                    // Save message to the recipient user
                    saveMessage(idSendingUser: idRecipientUser, idRecipient: idLoggedUser, messageSent: messageSent as Dictionary<String, Any>)
                    
                    var chat: Dictionary<String, Any> = [
                        "lastMessage": typedText
                    ]
                    
                    // Save chat for sending user
                    chat["idSending"] = idLoggedUser!
                    chat["idRecipient"] = idRecipientUser
                    chat["userName"] = self.nameContact
                    chat["userPhotoURL"] = self.contactPhotoURL
                    saveChat(idSending: idLoggedUser, idRecipient: idRecipientUser, chat: chat)
                    
                    // Save chat for recipient user
                    chat["idSending"] = idRecipientUser
                    chat["idRecipient"] = idLoggedUser!
                    chat["userName"] = self.nameLoggedUser
                    chat["userPhotoURL"] = self.urlLoggedUserPhoto
                    saveChat(idSending: idRecipientUser, idRecipient: idLoggedUser, chat: chat)
                    
                }
            }
        }
        
    }
    
    func saveChat(idSending: String, idRecipient: String, chat: Dictionary<String, Any>) {
        
        db.collection("chats")
        .document(idSending)
        .collection("last_chat")
        .document(idRecipient)
        .setData(chat)
        
    }
    
    func saveMessage(idSendingUser: String, idRecipient: String, messageSent: Dictionary<String, Any>) {
        
        db.collection("messages")
            .document(idSendingUser)
            .collection(idRecipient)
            .addDocument(data: messageSent)
        
        // Clean text field:
        message.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        addListenerRetrieveMessages()
    }
    
    func addListenerRetrieveMessages() {
        
        if let idRecipient = contact["id"] as? String {
            messagesListener = db.collection("messages")
            .document(idLoggedUser)
            .collection(idRecipient)
            .order(by: "date", descending: false)
                .addSnapshotListener { (querySnapshot, error) in
                    
                    // Clean list
                    self.listMessages.removeAll()
                    
                    // Retrieve data
                    if let snapshot = querySnapshot {
                        for document in snapshot.documents {
                            let data = document.data()
                            self.listMessages.append(data)
                        }
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                    
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        messagesListener.remove()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rightCell = tableView.dequeueReusableCell(withIdentifier: "messageCellRight", for: indexPath) as! MessagesTableViewCell
        
        let leftCell = tableView.dequeueReusableCell(withIdentifier: "messageCellLeft", for: indexPath) as! MessagesTableViewCell
        
        let rightImageCell = tableView.dequeueReusableCell(withIdentifier: "imageCellRight", for: indexPath) as! MessagesTableViewCell
        
        let leftImageCell = tableView.dequeueReusableCell(withIdentifier: "imageCellLeft", for: indexPath) as! MessagesTableViewCell
         
        let index = indexPath.row
        let data = self.listMessages[index]
        let text = data["text"] as? String
        let userId = data["userId"] as? String
        let URLimage = data["imageURL"] as? String
        
        if idLoggedUser == userId {
            
            if URLimage != nil {
                rightImageCell.imageRight.sd_setImage(with: URL(string: URLimage!), completed: nil)
                return rightImageCell
            }
            rightCell.rightMessageLabel.text = text
            return rightCell
        
        } else {
            if URLimage != nil {
                leftImageCell.imageLeft.sd_setImage(with: URL(string: URLimage!), completed: nil)
                return leftImageCell
            }
            leftCell.leftMessageLabel.text = text
            return leftCell
        }
                
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.listMessages.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
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
