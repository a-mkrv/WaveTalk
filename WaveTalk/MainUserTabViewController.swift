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
    
    var myProfile = Contact()
    var clientSocket = TCPSocket()
    var profileSettings = ProfileSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for viewController in self.viewControllers! {
            _ = viewController.view
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
