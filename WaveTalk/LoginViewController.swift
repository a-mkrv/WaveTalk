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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var wavesImage: UIImageView!
    var previewAnimated = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginInput.setBorderBottom()
        passwordInput.setBorderBottom()
        
        //TODO: Show animation only at the first start / relogin
        
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
    
    
    func alphaOffOn(value: CGFloat) {
        self.loginInput.alpha = value
        self.passwordInput.alpha = value
        self.loginButton.alpha = value
        self.signupButton.alpha = value
        self.forgotButton.alpha = value
    }
    
    
    @IBAction func loginPress(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: self.loginInput.text!, password: self.passwordInput.text!) { (user, error) in
            
            if error == nil {
                // Go to the HomeViewController (TabBar) if the login is sucessful
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarBoard")
                self.present(vc!, animated: true, completion: nil)
                
            } else {
                // Error
                SCLAlertView().showTitle( "Error", subTitle: "\nInvalid Login or Password\n",
                                          duration: 0.0, completeText: "Try again", style: .error, colorStyle: 0x4196BE
                )
            }
        }
    }
    
    
    @IBAction func signupPress(_ sender: Any) {
        performSegue(withIdentifier: "SignUp", sender: self)
    }
    
    
    @IBAction func forgotpassPress(_ sender: Any) {
        performSegue(withIdentifier: "ForgotPassword", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
