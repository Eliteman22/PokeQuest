//
//  ChatCellTableViewCell.swift
//  PocketQuest
//
//  Created by Flavio Lici on 8/9/16.
//  Copyright © 2016 Flavio Lici. All rights reserved.
//

import UIKit

class ChatCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var message: UITextView!
    
    @IBOutlet weak var pokeImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
