//
//  PokeFilterTableViewCell.swift
//  PocketQuest
//
//  Created by Flavio Lici on 8/7/16.
//  Copyright © 2016 Flavio Lici. All rights reserved.
//

import UIKit

class PokeFilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pokemonPicture: UIImageView!
    
    @IBOutlet weak var pokemonName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
