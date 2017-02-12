//
//  MainUserTabViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 12.02.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase

class MainUserTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //checkUserIsLoggedIn()
    }
    
    
    func checkUserIsLoggedIn() {
        if  FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print("LogoutError ", logoutError)
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginBoard")
        self.present(vc!, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
