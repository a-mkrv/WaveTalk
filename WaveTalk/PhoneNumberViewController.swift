//
//  PhoneNumberViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 28.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import Foundation


class PhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var numberTextField: UITextField!
    var delegate: ProfileSettingsProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.savePhoneNumber))
        self.navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)        
    }
    
    
    func savePhoneNumber(sender:UIButton) {
        delegate?.setPhoneNumber(newValue: numberTextField.text!)
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func setCodeBrackets(_ sender: UITextField) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
