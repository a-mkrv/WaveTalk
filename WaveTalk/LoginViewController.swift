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
import SwiftSocket

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginInput: FloatLabelTextField!
    @IBOutlet weak var passwordInput: FloatLabelTextField!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var wavesImage: UIImageView!
    
    var previewAnimated = true
    var authSocket: TCPClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authSocket = TCPClient(address: "127.0.0.1", port: 55155)
        authSocket?.connect(timeout: 10)
        
        let colorBorder = UIColor(red: 80/255.0, green: 114/255.0, blue: 153/255.0, alpha: 100.0/100.0).cgColor
        
        loginInput.setBorderBottom(colorBorder)
        passwordInput.setBorderBottom(colorBorder)
        
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
    
    
    private func sendRequest(using client: TCPClient) -> String? {
        if let login = self.loginInput.text, let pass = self.passwordInput.text {
            
            switch client.send(string: "AUTH" + login + " /s " + pass) {
            case .success:
                return readResponse(from: client)
            case .failure(let error):
                print(error)
                return nil
            }
            
        } else {
            return nil
        }
    }
    
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    
    @IBAction func loginPress(_ sender: Any) {
        if let response = sendRequest(using: authSocket!) {
            
            switch(response) {
            case "ERRA":
                SCLAlertView().showTitle( "Error", subTitle: "\nInvalid Login or Password\n", duration: 0.0, completeText: "Try again", style: .error, colorStyle: 0x4196BE)
                break
                
            case "OKEY":
                authSocket?.close()
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
        authSocket?.close()
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
