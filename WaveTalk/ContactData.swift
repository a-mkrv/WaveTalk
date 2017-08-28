//
//  DialogueSettings.swift
//  WaveTalk
//
//  Created by Anton Makarov on 30.12.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var username: String?
    var phoneNumber_or_Email: String?
    var lastPresenceTime: String?
    var profileImageURL: String?
    var notifications: Bool?
    var sex: String?
    var status: String?
    var pubKey: Key?
    var privateKey: Key?
    var id: String?
}

class FirebaseData: NSObject {
    var privateKey: String?
    var profileImageURL: String?
}

