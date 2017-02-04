//
//  ProfileSettingsViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 18.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, ProfileSettingsProtocol {
    
    @IBOutlet weak var profilePhotoImage: UIImageView!
    @IBOutlet weak var firstnameInput: UITextField!
    @IBOutlet weak var lastnameInput: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var delegate: ProfileSettingsProtocol?
    var pickImageController = UIImagePickerController()
    var profileSettings: ProfileSettings!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
        usernameLabel.text = profileSettings.userName
        phoneLabel.text = profileSettings.phoneNumber
        statusLabel.text = profileSettings.status
    }
    
    
    func initUI() {
        self.profilePhotoImage.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:
            #selector(loadProfilePhoto(_:))
            )
        )
        
        pickImageController.delegate = self
        pickImageController.allowsEditing = true
        
        profilePhotoImage.layer.cornerRadius = 52.0
        profilePhotoImage.clipsToBounds = true
        
        firstnameInput.setBorderBottom()
        lastnameInput.setBorderBottom()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                let userNameViewController = self.storyboard?.instantiateViewController(withIdentifier: "usernameVC") as! UserNameViewController
                userNameViewController.delegate = self
                self.navigationController?.pushViewController(userNameViewController, animated: true)
                
                break
            case 1:
                let phoneNumberViewController = self.storyboard?.instantiateViewController(withIdentifier: "phonenumberVC") as! PhoneNumberViewController
                phoneNumberViewController.delegate = self
                self.navigationController?.pushViewController(phoneNumberViewController, animated: true)
                
                break
            case 2:
                // Add status
                break
            default:
                break
            }
            
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
    
    
    func setUserName(newValue: String) {
        usernameLabel.text = newValue
        self.profileSettings.userName = newValue
    }
    
    func setPhoneNumber(newValue: String) {
        phoneLabel.text = newValue
        self.profileSettings.phoneNumber = newValue
    }
    
    
    func setStatus(newValue: String) {
        self.profileSettings.status = newValue
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
