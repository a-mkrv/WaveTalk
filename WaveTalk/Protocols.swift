//
//  SaveSettingsProtocol.swift
//  WaveTalk
//
//  Created by Anton Makarov on 22.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation

protocol NotificationSettingsProtocol {
    func setSound(newValue: Bool)
    func setVibrate(newValue: Bool)
    func setPopUp(newValue: Bool)
    func setAlertTime(newValue: String)
    func setRepeatTime(newValue: String)
}

protocol ProfileSettingsProtocol {
    func setOptionalInformation(firstName: String?, lastName: String?, gender: String?, age: String?, city: String?)
    func setUserName(newValue: String)
    func setPhoneNumber(newValue: String)
    func setStatus(newValue: String)
}

protocol UserListProtocol {
    func addNewContact(contact: Contact)
    func updateNotificationState(username: String, state: Bool)
}
