//
//  DialogueSettings.swift
//  WaveTalk
//
//  Created by Anton Makarov on 30.12.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit

class Dialogue: NSObject {
    var userName: String
    var lastMessage: String
    var lastPresenceTime: Int
    
    init(Name: String, Message: String, Time: Int) {
        self.userName = Name
        self.lastMessage = Message
        self.lastPresenceTime = Time
        super.init()
    }
}
