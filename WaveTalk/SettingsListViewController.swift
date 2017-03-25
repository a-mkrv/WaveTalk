//
//  SettingsHeaderViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 10.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase

class SettingsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationSettingsProtocol {
    
    @IBOutlet weak var firstLastName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var settingsList: UITableView!
    @IBOutlet weak var photoImage: UIImageView!
    
    var tcpDelegate: NetworkTCPProtocol?
    var notificationSettings = NotificationSettings()
    var profileSettings = ProfileSettings()
    
    let userDefaults = UserDefaults.standard
    let parameters = ["My Profile",  "Notifications", "Calls & Messages", "Privacy", "Media", "", "About", "Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProfileImage()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //FIXME:    Add a check for variability of data
        //          Badly to make a request each time to a database
        
        fetchUserAndSetupNavigationBarTitle()
    }
    
    
    func updateMyInfo() {
        firstLastName.text = profileSettings.firstName + " " + profileSettings.lastName
        userName.text = "@" + profileSettings.userName
        phoneNumber.text = "+" + profileSettings.phoneNumber
    }
    
    
    func fetchUserAndSetupNavigationBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? [String : AnyObject] {
                self.profileSettings.userName = (dictionary["username"] as? String)!
                self.profileSettings.status = (dictionary["status"] as? String)!
                self.profileSettings.phoneNumber = (dictionary["phoneNumber_or_Email"] as? String)!
                self.profileSettings.profileImageURL = (dictionary["profileImageURL"] as? String)!
                
                if let profileImageURL = self.profileSettings.profileImageURL {
                    self.photoImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                }
                
                self.updateMyInfo()
            }
        }, withCancel: nil)
    }
    
    
    func setProfileImage() {
        photoImage.layer.borderWidth = 1
        photoImage.layer.masksToBounds = false
        photoImage.layer.borderColor = UIColor(red:  58/255.0, green: 153/255.0, blue: 217/255.0, alpha: 30.0/100.0).cgColor
        
        photoImage.layer.cornerRadius = photoImage.frame.height/2
        photoImage.clipsToBounds = true
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
            else if (cellName == "My Profile") {
                let destinationController = VC as! ProfileSettingsViewController
                destinationController.profileSettings = profileSettings
            }
            
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            self.navigationController?.pushViewController(VC, animated: true)
        } else if cellName == "Log Out" {
            handleLogout()
        }
    }
    
    func handleLogout() {
        userDefaults.set("userIsEmpty", forKey: "myUserName")

        self.tcpDelegate?.setCancelConnect(request: "Cancel")

//        do {
//            try FIRAuth.auth()?.signOut()
//        } catch let logoutError {
//            print("LogoutError ", logoutError)
//        }
        
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
