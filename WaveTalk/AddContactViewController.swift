//
//  AddContactViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 12.02.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddContactViewController: UIViewController {

    @IBOutlet weak var requestField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestField.setBorderBottom()
    }

    
    @IBAction func addContact(_ sender: Any) {
        
        let rootRef = FIRDatabase.database().reference()
        let email = requestField.text
        
        //rootRef.child("users").child(user.uid).setValue(["username": email])

        rootRef.child("users").queryEqual(toValue: email, childKey: "users").observe(.value, with: { snapshot in
            if snapshot.exists() {
                print("user exists")
                
            } else if !snapshot.exists(){
                print("user doesn't exist")
                
            }
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
