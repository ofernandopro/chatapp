//
//  SettingsViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 15/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseUI

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var auth: Auth!
    var storage: Storage!
    var firestore: Firestore!
    var imagePicker = UIImagePickerController()
    var userId: String!
    
    @IBAction func logOutButton(_ sender: Any) {
        
        do {
            try auth.signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            self.displayMessage(title: "Error", message: "Error to sign out! Try again.")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self

        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
        
        self.retrieveLoggedUserId()
        
        self.retrieveUserData()
        
    }
    
    func retrieveLoggedUserId() {
        if let id = auth.currentUser?.uid {
            self.userId = id
        }
    }
    
    func retrieveUserData() {
        
        let usersRef = self.firestore
          .collection("users")
        .document(userId)
        
        usersRef.getDocument { (snapshot, error) in
            
            if let data = snapshot?.data() {
                
                let userName = data["name"] as? String
                let userEmail = data["email"] as? String

                self.nameLabel.text = userName
                self.emailLabel.text = userEmail
                
                if let imageURL = data["imageURL"] as? String {
                    self.profileImage.sd_setImage(with: URL(string: imageURL), completed: nil)
                }
                
            }
            
        }
        
    }
    
    @IBAction func pickProfilePictureButton(_ sender: Any) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let retrievedImage = info[
            UIImagePickerController.InfoKey.originalImage
        ] as! UIImage
        
        saveProfileImageOnFirebase(retrievedImage: retrievedImage)
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func saveProfileImageOnFirebase(retrievedImage: UIImage) {
        
        self.profileImage.image = retrievedImage
        
        let images = storage
            .reference()
            .child("images")
        
        if let uploadImage = retrievedImage.jpegData(compressionQuality: 0.5) {
            
            if let loggedUser = auth.currentUser {
                
                let userId = loggedUser.uid
                let imageName = "\(userId).jpg"
                
                let profileImageRef = images.child("profile").child(imageName)
                    profileImageRef.putData(uploadImage, metadata: nil) { (metaData, error) in
                        
                        if error == nil {
                            
                            profileImageRef.downloadURL { (url, error) in
                                if let imageURL = url?.absoluteString {
                                    self.firestore
                                      .collection("users")
                                    .document(userId)
                                      .updateData([
                                          "imageURL": imageURL
                                      ])
                                }
                            }
                            
                        } else {
                            self.displayMessage(title: "Error", message: "Error updating your profile picture")
                        }
                }
            }
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
