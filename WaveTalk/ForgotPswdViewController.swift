//
//  ForgotPswdViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 20.11.16.
//  Copyright © 2016 Anton Makarov. All rights reserved.
//

import UIKit

class ForgotPswdViewController: UIViewController {
    
    @IBOutlet weak var resetPasswordField: FloatLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetPasswordField.setBorderBottom()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resetPasswordField.resignFirstResponder()
        
        return true
    }
    
    
    @IBAction func resetPassword(_ sender: Any) {
        performSegue(withIdentifier: "resetToLogin", sender: self)
        
    }
}
