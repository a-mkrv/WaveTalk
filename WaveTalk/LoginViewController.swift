//
//  LoginViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 20.11.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var wavesImage: UIImageView!
    var animated = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !animated {
            self.logoImage.frame.origin.y -= 200
            self.wavesImage.frame.origin.y += 200
            self.logoImage.alpha = 0
            self.alphaOffOn(value: 0)
            
            animated = true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    }
    
    func alphaOffOn(value: CGFloat) {
        self.loginInput.alpha = value
        self.passwordInput.alpha = value
        self.loginButton.alpha = value
        self.signupButton.alpha = value
        self.forgotButton.alpha = value
    }
    
    @IBAction func loginPress(_ sender: Any) {
        performSegue(withIdentifier: "mainTabBar", sender: self)
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
