//
//  ProfileSettings.swift
//  WaveTalk
//
//  Created by Anton Makarov on 19.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation

class ProfileSettings {
    
    let defaults = UserDefaults.standard
    
    var firstName: String {
        get {
            let fName = defaults.object(forKey: "FirstName") as? String
            
            if fName != nil {
                return fName!
            }
            else {
                return ""
            }
        }
        set (newVal) {
            defaults.set(newVal, forKey: "FirstName")
        }
    }
    
    var lastName: String {
        get {
            let lName = defaults.object(forKey: "LastName") as? String
            
            if lName != nil {
                return lName!
            }
            else {
                return ""
            }
        }
        set (newVal) {
            defaults.set(newVal, forKey: "LastName")
        }
    }
    
    var userName: String {
        get {
            let uName = defaults.object(forKey: "UserName") as? String
            
            if uName != nil {
                return uName!
            }
            else {
                return ""
            }
        }
        set (newVal) {
            defaults.set(newVal, forKey: "UserName")
        }
    }
    
    var phoneNumber: String {
        get {
            let pNumber = defaults.object(forKey: "PhoneNumber") as? String
            
            if pNumber != nil {
                return pNumber!
            }
            else {
                return ""
            }
        }
        set (newVal) {
            defaults.set(newVal, forKey: "PhoneNumber")
        }
    }
    
    var status: String {
        get {
            let stat = defaults.object(forKey: "Status") as? String
            
            if stat != nil {
                return stat!
            }
            else {
                return ""
            }
        }
        set (newVal) {
            defaults.set(newVal, forKey: "Status")
        }
    }
    
    var profileImageURL: String?
    var age: String = "0"
    var gender: String = "Unknown"
    var city: String = "Unknown"
    
    init(firstName: String, lastName: String, userName: String, phoneNumber: String, status: String, profileImageURL: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.phoneNumber = phoneNumber
        self.status = status
        self.profileImageURL = profileImageURL
    }
    
    
    init () {
    }
}
