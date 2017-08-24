//
//  ProfileSettingsViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 18.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate,  ProfileSettingsProtocol {
    
    @IBOutlet weak var profilePhotoImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var delegate: ProfileSettingsProtocol?
    var pickImageController = UIImagePickerController()
    var profileSettings: ProfileSettings!
    var profileSocket = TCPSocket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        initUI()
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        profileSettings = tabBarVC.profileSettings
        profileSocket = tabBarVC.clientSocket
        
        usernameLabel.text = "@" + profileSettings.userName
        phoneLabel.text = profileSettings.phoneNumber
        statusLabel.text = profileSettings.status
        
        if (profileSettings.profileImageURL?.characters.count)! > 2 {
            profilePhotoImage.loadImageUsingCacheWithUrlString(urlString: profileSettings.profileImageURL!)
        } else {
            //profilePhotoImage.loadImageUsingCacheWithUrlString(urlString: "#" + profileSettings.userName + " " + profileSettings.profileImageURL!)
        }
    }
    
    
    func initUI() {
        self.profilePhotoImage.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:
            #selector(loadProfilePhoto(_:))
            )
        )
        
        pickImageController.delegate = self
        pickImageController.allowsEditing = true
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                let userNameViewController = self.storyboard?.instantiateViewController(withIdentifier: "usernameVC") as! UserNameViewController
                userNameViewController.delegate = self
                userNameViewController.userName = profileSettings.userName
                self.navigationController?.pushViewController(userNameViewController, animated: true)
                
                break
            case 1:
                let phoneNumberViewController = self.storyboard?.instantiateViewController(withIdentifier: "phonenumberVC") as! PhoneNumberViewController
                phoneNumberViewController.delegate = self
                phoneNumberViewController.phoneNumber = profileSettings.phoneNumber
                self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
                
                break
            case 2:
                let statusViewController = self.storyboard?.instantiateViewController(withIdentifier: "statusVC") as! StatusViewController
                statusViewController.delegate = self
                statusViewController.curStatus = profileSettings.status
                self.navigationController?.pushViewController(statusViewController, animated: true)
                
                break
            default:
                break
            }
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            let optionalInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "optionalInfoVC") as! OptionalInfoViewController

            optionalInfoViewController.delegate = self
            self.navigationController?.pushViewController(optionalInfoViewController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func loadProfilePhoto(_ recognizer: UIPanGestureRecognizer) {
        let alertController = UIAlertController(title: "Update Profile Photo", message: "Choose from", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            action in
            self.pickImageFromCamera()
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) {
            action in
            self.pickImageFromLibrary()
        }
        
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(buttonCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func pickImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.camera
            self.present(pickImageController, animated: true, completion: nil)
        }
    }
    
    
    func pickImageFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(pickImageController, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            profilePhotoImage.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func updateUserInfoInDB() {
        
        var sendUpInfo: String = "UPUI" + profileSettings.userName + " /s "
        sendUpInfo.append(profileSettings.firstName + " /s " + profileSettings.lastName + " /s ")
        sendUpInfo.append(profileSettings.phoneNumber + " /s " + profileSettings.gender + " /s ")
        sendUpInfo.append(profileSettings.age + " /s " + profileSettings.city + " /s ")
        sendUpInfo.append(profileSettings.status)
        
        switch profileSocket.client.send(string: sendUpInfo) {
        case .success:
            Logger.debug(msg: "Success update" as AnyObject)
        case .failure(let error):
            Logger.error(msg: error as AnyObject)
        }
    }
    
    
    ///////////////////////////////////
    // PROTOCOL'S METHODS
    
    func setOptionalInformation(firstName: String?, lastName: String?, gender: String?, age: String?, city: String?) {
        self.profileSettings.firstName = firstName!
        self.profileSettings.lastName = lastName!
        self.profileSettings.gender = gender!
        self.profileSettings.age = age!
        self.profileSettings.city = city!
        
        updateUserInfoInDB()
    }
    
    
    func setUserName(newValue: String) {
        usernameLabel.text = "@" + newValue
        self.profileSettings.userName = newValue
        
        updateUserInfoInDB()
    }
    
    
    func setPhoneNumber(newValue: String) {
        phoneLabel.text = "+" + newValue
        self.profileSettings.phoneNumber = newValue
        
        updateUserInfoInDB()
    }
    
    
    func setStatus(newValue: String) {
        statusLabel.text = newValue
        self.profileSettings.status = newValue
        
        updateUserInfoInDB()
    }
    
    ///////////////////////////////////
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
