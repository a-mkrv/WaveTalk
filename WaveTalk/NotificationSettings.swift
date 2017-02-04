//
//  Settings.swift
//  WaveTalk
//
//  Created by Anton Makarov on 19.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation

class NotificationSettings {
    
    let defaults = UserDefaults.standard
    
    var Alert: String {
        get {
            let alertStr = defaults.object(forKey: "AlertTime") as? String
            
            if alertStr != nil {
                return alertStr!
            }
            else {
                return "On"
            }
        }
        set (newVal) {
            defaults.set(newVal, forKey: "AlertTime")
        }
    }
    
    var Sound: Bool {
        get {
            return defaults.bool(forKey: "Sound")
        }
        set (newVal) {
            defaults.set(newVal, forKey: "Sound")
        }
    }
    
    var Vibrate: Bool {
        get {
            return defaults.bool(forKey: "Vibrate")
        }
        set (newVal) {
            defaults.set(newVal, forKey: "Vibrate")
        }
    }
    
    var PopUp: Bool {
        get {
            return defaults.bool(forKey: "PopUp")
        }
        set (newVal) {
            defaults.set(newVal, forKey: "PopUp")
        }
    }
    
    var Repeat: String {
        get {
            let repeatStr = defaults.object(forKey: "RepeatTime") as? String
            
            if repeatStr != nil {
                return repeatStr!
            }
            else {
                return "15 minutes"
            }
        }
        set (newVal) {
            defaults.set(newVal, forKey: "RepeatTime")
        }
    }
    
    init(Alert: String, Sound: Bool, Vibrate: Bool, PopUp: Bool, Repeat: String) {
        self.Alert = Alert
        self.Sound = Sound
        self.Vibrate = Vibrate
        self.PopUp = PopUp
        self.Repeat = Repeat
    }
    
    
    init () {
    }
    
}
