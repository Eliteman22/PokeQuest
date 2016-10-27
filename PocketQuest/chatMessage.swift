//
//  chatMessage.swift
//  PocketQuest
//
//  Created by Flavio Lici on 8/8/16.
//  Copyright © 2016 Flavio Lici. All rights reserved.
//

import Foundation

class chatMessage: NSObject {
    var image: String
    var text: String
    
    init(image: String, text: String) {
        self.image = image
        self.text = text
    }
}