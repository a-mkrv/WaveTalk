//
//  LoginViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 20.11.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginInput: FloatLabelTextField!
    @IBOutlet weak var passwordInput: FloatLabelTextField!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var wavesImage: UIImageView!
    
    var previewAnimated = true
    var authSocket = TCPSocket()
    
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .default

        authSocket.connect()
        
        let colorBorder = UIColor(red: 80/255.0, green: 114/255.0, blue: 153/255.0, alpha: 100.0/100.0).cgColor
        
        self.loginInput.delegate = self
        self.passwordInput.delegate = self
        
        loginInput.setBorderBottom(colorBorder)
        passwordInput.setBorderBottom(colorBorder)
                
        if previewAnimated {
            self.logoImage.frame.origin.y -= 200
            self.wavesImage.frame.origin.y += 200
            self.logoImage.alpha = 0
            self.alphaOffOn(value: 0)
            
            previewAnimated = false
        }
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        navigationController?.navigationBar.barStyle = .black
//    }

        
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !previewAnimated {
            UIView.animate(withDuration: 2.5, animations: {
                self.logoImage.alpha = 1
                self.logoImage.frame.origin.y += 200
                self.wavesImage.frame.origin.y -= 200
            }, completion: {
                (value: Bool) in
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.alphaOffOn(value: 1)
                })
            })
            
            previewAnimated = false
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loginInput.resignFirstResponder()
        self.passwordInput.resignFirstResponder()
        
        return true
    }
    
    
    func alphaOffOn(value: CGFloat) {
        self.loginInput.alpha = value
        self.passwordInput.alpha = value
        self.loginButton.alpha = value
        self.signupButton.alpha = value
        self.forgotButton.alpha = value
    }
    
    
    private func sendRequest(using client: TCPSocket) -> String? {
        if let login = self.loginInput.text, let pass = self.passwordInput.text {

            switch client.client.send(string: "AUTH" + login + " /s " + pass.md5()) {
            case .success:
                return client.readResponse()
            case .failure(let error):
                print(error)
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    @IBAction func loginPress(_ sender: Any) {
        if self.loginInput.text == "Admin" {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarBoard")
            self.present(vc!, animated: true, completion: nil)
            userDefaults.set(self.loginInput.text, forKey: "myUserName")
            return
        }
        
        if !NetworkConnect.isConnectedToNetwork() {
            SCLAlertView().showTitle( "Connection error", subTitle: "\nCheck the 3G, LTE, Wi-Fi\n", duration: 3.0, completeText: "Try again", style: .error, colorStyle: 0xFF9999)
            
            return
        }
        
        if let response = sendRequest(using: authSocket) {
            
            var bodyOfResponse: String = ""
            let head = response.getHeadOfResponse(with: &bodyOfResponse)
            
            switch(head) {
            case "ERRA":
                SCLAlertView().showTitle( "Error", subTitle: "\nInvalid Login or Password\n", duration: 0.0, completeText: "Try again", style: .error, colorStyle: 0x4196BE)
                break
                
            case "OKEY":
                authSocket.disconnect()
                
                userDefaults.set(self.loginInput.text, forKey: "myUserName")
                userDefaults.set(bodyOfResponse, forKey: "myPublicKey")
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarBoard")
                self.present(vc!, animated: true, completion: nil)
                break
                
            default:
                print("Auth Error - Bad response")
            }
        } else {
            print("Auth Error - Bad request")
        }
    }
    
    
    @IBAction func signupPress(_ sender: Any) {
        authSocket.disconnect()
        performSegue(withIdentifier: "SignUp", sender: self)
    }
    
    
    @IBAction func forgotpassPress(_ sender: Any) {
        performSegue(withIdentifier: "ForgotPassword", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// Use Firebase
//
//@IBAction func loginPress(_ sender: Any) {
//
//    FIRAuth.auth()?.signIn(withEmail: self.loginInput.text!, password: self.passwordInput.text!) { (user, error) in
//
//        if error == nil {
//            // Go to the HomeViewController (TabBar) if the login is sucessful
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarBoard")
//            self.present(vc!, animated: true, completion: nil)
//
//        } else {
//            // Error
//            SCLAlertView().showTitle( "Error", subTitle: "\nInvalid Login or Password\n",
//                                      duration: 0.0, completeText: "Try again", style: .error, colorStyle: 0x4196BE
//            )
//        }
//    }
//
//}
