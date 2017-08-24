//
//  SettingsHeaderViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 10.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class SettingsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationSettingsProtocol {
    
    @IBOutlet weak var firstLastName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var settingsList: UITableView!
    @IBOutlet weak var photoImage: UIImageView!
    
    var myProfile = Contact()
    var settingsSocket = TCPSocket()
    var notificationSettings = NotificationSettings()
    var profileSettings = ProfileSettings()
    
    let userDefaults = UserDefaults.standard
    let parameters = ["My Profile",  "Notifications", "Calls & Messages", "Privacy", "Media", "", "About", "Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        
        // After registration it crashes
        photoImage.loadImageUsingCacheWithUrlString(urlString: tabBarVC.myProfile.profileImageURL!)
        //
        photoImage.layer.borderWidth = 1
        photoImage.layer.masksToBounds = false
        photoImage.layer.borderColor = UIColor(red:  58/255.0, green: 153/255.0, blue: 217/255.0, alpha: 30.0/100.0).cgColor
        
        photoImage.layer.cornerRadius = photoImage.frame.height/2
        photoImage.clipsToBounds = true
        
        settingsSocket = tabBarVC.clientSocket
        profileSettings = tabBarVC.profileSettings
        profileSettings.profileImageURL = tabBarVC.myProfile.profileImageURL
        myProfile = tabBarVC.myProfile
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //(self.tabBarController  as! MainUserTabViewController).finishReadingQueue()
        //fetchUserAndSetupNavigationBarTitle()
        //(self.tabBarController  as! MainUserTabViewController).startReadingQueue(for: settingsSocket.client)
    }
    
    
    func updateMyInfo() {
        firstLastName.text = profileSettings.firstName + " " + profileSettings.lastName
        
        if (firstLastName.text == " ") {
            firstLastName.text = "First / Last Name"
            firstLastName.textColor = UIColor.lightGray
        } else {
            firstLastName.textColor = .black
        }
        
        userName.text = "@" + profileSettings.userName
        phoneNumber.text = "+" + profileSettings.phoneNumber
    }
    
    
    func setProfileImage() {
//        FIRDatabase.database().reference().child("users").child(profileSettings.userName).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let dictionary = snapshot.value as? [String : Any] {
//                for each in dictionary {
//                    self.profileSettings.profileImageURL = each.1 as? String
//                    self.photoImage.loadImageUsingCacheWithUrlString(urlString: each.1 as! String)
//                }
//            }
//        })
        
        if (myProfile.profileImageURL?.characters.count)! > 2 {
            photoImage.loadImageUsingCacheWithUrlString(urlString: myProfile.profileImageURL!)
        } else {
            photoImage.loadImageUsingCacheWithUrlString(urlString: "#" + myProfile.username! + " " + myProfile.profileImageURL!)
        }
        
        photoImage.layer.borderWidth = 1
        photoImage.layer.masksToBounds = false
        photoImage.layer.borderColor = UIColor(red:  58/255.0, green: 153/255.0, blue: 217/255.0, alpha: 30.0/100.0).cgColor
        
        photoImage.layer.cornerRadius = photoImage.frame.height/2
        photoImage.clipsToBounds = true
    }
    
    
    func fetchUserAndSetupNavigationBarTitle() {
        if let response = sendRequest(using: settingsSocket) {
            
            var bodyOfResponse: String = ""
            let head = response.getHeadOfResponse(with: &bodyOfResponse)
            
            switch(head) {
            case "INFN": //Bad response
                
                break
                
            case "INFP": //Get information
                let userData = bodyOfResponse.components(separatedBy: " /s ")
                // 0 - Sex, 1 - Age, 2 - City, 3 - OnlineStatus, 4 - Email/Phone, 5 - LiveStatus
                
                myProfile.lastPresenceTime = userData[3]
                myProfile.phoneNumber_or_Email = userData[4]
                myProfile.status = userData[5]
                
                profileSettings.gender = userData[0]
                profileSettings.age = userData[1]
                profileSettings.city = userData[2]
                profileSettings.firstName = userData[6]
                profileSettings.lastName = userData[7]
                profileSettings.phoneNumber = userData[4]
                profileSettings.status = userData[5]
                profileSettings.userName = myProfile.username!
                
                self.setProfileImage()
                self.updateMyInfo()
                
                break
                
            default:
                Logger.error(msg: "Auth Error - Bad response" as AnyObject)
            }
        } else {
            Logger.error(msg: "Auth Error - Bad request" as AnyObject)
        }
    }
    
    private func sendRequest(using client: TCPSocket) -> String? {
        var request = "GETI"
        
        guard let myUserName = myProfile.username else {
            Logger.error(msg: "UserName is Empty" as AnyObject)
            return nil
        }
        
        request.append(myUserName)
        
        switch client.client.send(string: request) {
        case .success:
            return client.readResponse()
        case .failure(let error):
            Logger.error(msg: error as AnyObject)
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parameters.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSettings", for: indexPath) as! SettingsViewCell
        
        cell.nameOfSetting.text = parameters[indexPath.row]
        cell.imageSetting?.image = UIImage(named: parameters[indexPath.row])
        
        if cell.nameOfSetting!.text == "" {
            cell.selectionStyle = UITableViewCellSelectionStyle.none;
            cell.isUserInteractionEnabled = false
        } else if cell.nameOfSetting!.text == "Log Out" {
            cell.nameOfSetting!.textColor = UIColor(red:  229/255.0, green: 77/255.0, blue: 66/255.0, alpha: 80.0/100.0)
            
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! SettingsViewCell
        let cellName: String = cell.nameOfSetting!.text!
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        if cellName != "" && cellName != "Log Out" {
            let VC = storyboard.instantiateViewController(withIdentifier: parameters[indexPath.row])
            VC.navigationItem.title = parameters[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            
            if (cellName == "Notifications") {
                let destinationController = VC as! NotificationSettingsViewController
                destinationController.delegate = self
                destinationController.notificationSettings = notificationSettings
            }
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(VC, animated: true)
        } else if cellName == "Log Out" {
            handleLogout()
        }
    }
    
    func handleLogout() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Confirm the Log Out", target:self, selector:#selector(self.logOut))
        alertView.addButton("Cancel") {}
        
        alertView.showTitle(
            "Sign out of account",
            subTitle: "\n",
            style: .warning,
            colorStyle: 0x708090,
            colorTextButton: 0xFFFFFF
        )
    }
    
    func logOut() {
        userDefaults.set("userIsEmpty", forKey: "myUserName")
        settingsSocket.disconnect()
        (self.tabBarController  as! MainUserTabViewController).finishReadingQueue()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "welcomePage")
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    ///////////////////////////////////
    // PROTOCOL'S METHODS
    
    func setSound(newValue: Bool) {
        self.notificationSettings.Sound = newValue
    }
    
    func setVibrate(newValue: Bool) {
        self.notificationSettings.Vibrate = newValue
    }
    
    func setPopUp(newValue: Bool) {
        self.notificationSettings.PopUp = newValue
    }
    
    func setAlertTime(newValue: String) {
        self.notificationSettings.Alert = newValue
    }
    
    func setRepeatTime(newValue: String) {
        self.notificationSettings.Repeat = newValue
    }
    
    ///////////////////////////////////
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// Use Firebase
//
//func fetchUserAndSetupNavigationBarTitle() {
//    guard let uid = FIRAuth.auth()?.currentUser?.uid else {
//        return
//    }
//
//    FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {
//        (snapshot) in
//
//        if let dictionary = snapshot.value as? [String : AnyObject] {
//            self.profileSettings.userName = (dictionary["username"] as? String)!
//            self.profileSettings.status = (dictionary["status"] as? String)!
//            self.profileSettings.phoneNumber = (dictionary["phoneNumber_or_Email"] as? String)!
//            self.profileSettings.profileImageURL = (dictionary["profileImageURL"] as? String)!
//
//            if let profileImageURL = self.profileSettings.profileImageURL {
//                self.photoImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
//            }
//
//            self.updateMyInfo()
//        }
//    }, withCancel: nil)
//}
