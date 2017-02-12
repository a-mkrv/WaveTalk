//
//  SignUpViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 20.11.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import SkyFloatingLabelTextField


class RegistrationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Add checking of validity in realtime
        //TODO: Add phone field
        
        usernameField.setRegistrationFieldStyleWith(title: "Username")
        usernameField.delegate = self
        passwordField.setRegistrationFieldStyleWith(title: "Password")
        emailField.setRegistrationFieldStyleWith(title: "Email")
    }
    
    
    
    @IBAction func createAccount(_ sender: Any) {
        var login = ""
        var email = ""
        var paswd = ""
        
        login = validData(inputField: usernameField, subTitle: "\nUsername must be greater\n than 5 characters", minLength: 5)
        
        if login != "" {
            email = validData(inputField: emailField, subTitle: "\nPlease enter a valid email address", minLength: 6)
        }
        
        if email != "" && login != "" {
            paswd = validData(inputField: passwordField, subTitle: "\nPassword must be greater\n than 6 characters", minLength: 6)
        }
        
        
        if (login != "" && email != "" && paswd != "") {
            FIRAuth.auth()?.createUser(withEmail: email, password: paswd, completion: { (user: FIRUser?, error) in
                if error == nil {
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    
                    alertView.addButton("Go to Log In") {
                        self.backToLogin(self)
                    }
                    alertView.showSuccess("Successful registration!", subTitle: "Welcome to Whisper")
                } else {
                    //registration failure
                }
            })
        }
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
    
    
    @IBAction func backToLogin(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginBoard")
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
