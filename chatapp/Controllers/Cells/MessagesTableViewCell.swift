//
//  MessagesTableViewCell.swift
//  chatapp
//
//  Created by Fernando Moreira on 19/06/21.
//  Copyright © 2021 Fernando Moreira. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {

    @IBOutlet weak var imageRight: UIImageView!
    @IBOutlet weak var imageLeft: UIImageView!
    
    @IBOutlet weak var rightMessageLabel: UILabel!
    @IBOutlet weak var leftMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
