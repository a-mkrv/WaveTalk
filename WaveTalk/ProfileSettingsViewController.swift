//
//  ProfileSettingsViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 18.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var profilePhotoImage: UIImageView!
    @IBOutlet weak var firstnameInput: UITextField!
    @IBOutlet weak var lastnameInput: UITextField!
    
    var pickImageController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // TODO: implement Select Row

        
        if (indexPath.section == 1) {
            switch (indexPath.row) {
            case 0:
                
                break
            case 1:
                
                break
            case 2:
                
                break
            default:
                break
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
