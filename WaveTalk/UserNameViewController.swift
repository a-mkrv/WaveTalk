//
//  UserNameViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 28.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class UserNameViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    var delegate: ProfileSettingsProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveUserName))
        self.navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        
        usernameTextField.setBorderBottom()
    }
    
    func saveUserName (sender:UIButton) {
        delegate?.setUserName(newValue: usernameTextField.text!)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
