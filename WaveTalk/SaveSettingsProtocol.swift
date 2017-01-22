//
//  SaveSettingsProtocol.swift
//  WaveTalk
//
//  Created by Anton Makarov on 22.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation

protocol SaveSettingsProtocol {
    func setSound(newValue: Bool)
    func setVibrate(newValue: Bool)
    func setPopUp(newValue: Bool)
    func setAlertTime(newValue: String)
    func setRepeatTime(newValue: String)
}
