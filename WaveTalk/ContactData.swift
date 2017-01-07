//
//  DialogueSettings.swift
//  WaveTalk
//
//  Created by Anton Makarov on 30.12.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit

class Contact {
    var userName = ""
    var lastMessage = ""
    var lastPresenceTime = "..."
    var phoneNumber = ""
    var photoImage = ""
    
    init(userName: String, lastMessage: String, lastPresenceTime: String = "...", phoneNumber: String, photoImage: String) {
        self.userName = userName
        self.lastMessage = lastMessage
        self.lastPresenceTime = lastPresenceTime
        self.phoneNumber = phoneNumber
        self.photoImage = photoImage
    }
}
