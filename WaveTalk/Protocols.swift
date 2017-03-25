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
    func setFirstOrLastName(name: String, newValue: String)
    func setUserName(newValue: String)
    func setPhoneNumber(newValue: String)
    func setStatus(newValue: String)
}

protocol NetworkTCPProtocol {
    func setCancelConnect(request: String)
}


