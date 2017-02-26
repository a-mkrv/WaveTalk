//
//  SignUpViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 20.11.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SCLAlertView
import SkyFloatingLabelTextField


class RegistrationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userProfilePhoto: UIImageView!
    
    var pickImageController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Add checking of validity in realtime
        //TODO: Add phone field
        
        initUI()
    }
    
    
    func initUI() {
        self.userProfilePhoto.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:
            #selector(loadProfilePhotos(_:))
            )
        )
        
        userProfilePhoto.isUserInteractionEnabled = true
        userProfilePhoto.layer.cornerRadius = 64.0
        userProfilePhoto.clipsToBounds = true
        
        pickImageController.delegate = self
        pickImageController.allowsEditing = true
        
        usernameField.setRegistrationFieldStyleWith(title: "Username")
        usernameField.delegate = self
        passwordField.setRegistrationFieldStyleWith(title: "Password")
        emailField.setRegistrationFieldStyleWith(title: "Email")
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
        var login = ""
        var email = ""
        var paswd = ""
        let status = "Hello! Now I'm here, too!"
        
        login = validData(inputField: usernameField, subTitle: "\nUsername must be greater\n than 5 characters", minLength: 5)
        
        if login != "" {
            email = validData(inputField: emailField, subTitle: "\nPlease enter a valid email address", minLength: 6)
        }
        
        if email != "" && login != "" {
            paswd = validData(inputField: passwordField, subTitle: "\nPassword must be greater\n than 6 characters", minLength: 6)
        }
        
        //TODO: Change the registration process - to make sure the phone number (add a field) and change emeyl binding (optional)
        
        if (login != "" && email != "" && paswd != "") {
            FIRAuth.auth()?.createUser(withEmail: email, password: paswd, completion: { (user: FIRUser?, error) in
                
                if error == nil {
                    
                    guard let uid = user?.uid else {
                        return
                    }
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
                    
                    if let profileImage = self.userProfilePhoto.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                        
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            
                            //TODO: Add "Please wait..." dialog.
                            
                            if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                                
                                let values = ["username" : login, "phoneNumber_or_Email" : email, "status" : status, "lastPresenceTime" : String(describing: Date()), "profileImageURL" : profileImageURL]
                                
                                self.registerUserIntoWithUI(uid: uid, values: values as [String : AnyObject])
                            }
                        })
                    }
                } else {
                    SCLAlertView().showTitle( "Registration Error", subTitle: "\n\nUser with the same data already exists", duration: 0.0, completeText: "Ok", style: .error, colorStyle: 0x4196BE)
                }
            })
        }
    }
    
    func registerUserIntoWithUI(uid: String, values: [String: AnyObject]) {
        
        let ref = FIRDatabase.database().reference(fromURL: "https://wavetalk-d3236.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            } else {
                print("Saved user info into Firebase DB")
            }
        })
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Go to Log In") {
            self.backToLogin(self)
        }
        
        alertView.showSuccess("Successful registration!", subTitle: "Welcome to Whisper")
    }
    
    
    func validData(inputField: UITextField, subTitle: String, minLength: Int) -> String {
        var field: String = ""
        
        for view in inputField.subviews {
            if view.isKind(of: UITextField.self) {
                field = (view as! UITextField).text!
                
                if (field.characters.count) < minLength {
                    if inputField == emailField && !isValidEmail(emailStr: field){
                        SCLAlertView().showTitle(
                            "Invalid", subTitle: subTitle,
                            duration: 0.0, completeText: "OK", style: .error, colorStyle: 0x4196BE
                        )
                    } else {
                        SCLAlertView().showTitle(
                            "Invalid", subTitle: subTitle,
                            duration: 0.0, completeText: "OK", style: .error, colorStyle: 0x4196BE
                        )
                    }
                    field = ""
                }
            }
        }
        return field
    }
    
    
    func isValidEmail(emailStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let email = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return email.evaluate(with: emailStr)
    }
    
    
    func loadProfilePhotos(_ recognizer: UIPanGestureRecognizer) {
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
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            userProfilePhoto.image = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backToLogin(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginBoard")
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
