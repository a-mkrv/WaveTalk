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
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginInput.delegate = self
        self.passwordInput.delegate = self
        
        initUI()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    func initUI() {
        setNeedsStatusBarAppearanceUpdate()
        
        loginInput.setBorderBottom(UIColor.getColorBorder())
        passwordInput.setBorderBottom(UIColor.getColorBorder())
        
        if previewAnimated {
            self.logoImage.frame.origin.y -= 200
            self.wavesImage.frame.origin.y += 200
            self.logoImage.alpha = 0
            self.alphaOffOn(value: 0)
            
            previewAnimated = false
        }
    }
    
    
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
    
    
    @IBAction func loginPress(_ sender: Any) {
        
        if !NetworkConnect.isConnectedToNetwork() {
            SCLAlertView().showTitle("Connection error", subTitle: "\nCheck the 3G, LTE, Wi-Fi\n", style: .error, closeButtonTitle: "Try again", timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 3.0, timeoutAction: {}), colorStyle: 0xFF9999, animationStyle: .topToBottom)
            return
        }
        
        if (self.passwordInput.text?.count == 0) || (self.loginInput.text?.count == 0) {
            SCLAlertView().showTitle("Impty field", subTitle: "\nPlease enter all data\n", style: .error, closeButtonTitle: "Ok", timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 3.0, timeoutAction: {}), colorStyle: 0xFF9999, animationStyle: .topToBottom)
            return
        }
        
        let alertViewResponder: SCLAlertViewResponder = SCLAlertView().showTitle("Logging...", subTitle: "\nVerification of data\n", style: .wait, colorStyle: 0x4196BE, animationStyle: .noAnimation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let pass = (self.passwordInput.text!.md5() + self.loginInput.text!).md5()
            Auth.auth().signIn(withEmail: self.loginInput.text!, password: pass) { (user, error) in
                
                if error == nil {
                    // Go to the HomeViewController (TabBar) if the login is sucessful
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarBoard")
                    self.present(vc!, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        alertViewResponder.close()
                        SCLAlertView().showTitle("Logging error", subTitle: "\nInvalid Login or Password\n", style: .error, closeButtonTitle: "Try againOk", timeout: SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 3.0, timeoutAction: {}), colorStyle: 0xFF9999, animationStyle: .topToBottom)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
