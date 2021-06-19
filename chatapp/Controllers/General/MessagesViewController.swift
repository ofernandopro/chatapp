//
//  MessagesViewController.swift
//  chatapp
//
//  Created by Fernando Moreira on 18/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

}
