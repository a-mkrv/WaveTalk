//
//  ProfileSettingsViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 18.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

extension UITextField {
    func setBorderBottom() {
        let borderBottom = CALayer()
        let borderWidth = CGFloat(2.0)
        borderBottom.borderColor = UIColor(red: 80/255.0, green: 114/255.0, blue: 153/255.0, alpha: 100.0/100.0).cgColor
        borderBottom.frame = CGRect(x: 0, y: self.frame.height - 1.0, width: self.frame.width , height: self.frame.height - 1.0)
        borderBottom.borderWidth = borderWidth
        self.layer.addSublayer(borderBottom)
        self.layer.masksToBounds = true
    }
}

class ProfileSettingsViewController: UITableViewController {

    @IBOutlet weak var firstnameInput: UITextField!
    @IBOutlet weak var lastnameInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstnameInput.setBorderBottom()
        lastnameInput.setBorderBottom()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
