//
//  OptionalInfoViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 30.03.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class OptionalInfoViewController: UIViewController {

    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var genderCheckBox: UISegmentedControl!
    @IBOutlet weak var ageInput: UITextField!
    @IBOutlet weak var cityInput: UITextField!
    
    var gender = ""
    var delegate: ProfileSettingsProtocol?
    var profileSettings = ProfileSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.saveInformation))
        self.navigationItem.setRightBarButton(rightAddBarButtonItem, animated: true)
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        profileSettings = tabBarVC.profileSettings
        
        initUI()
    }

    
    func initUI() {
        firstNameInput.setBorderBottom()
        firstNameInput.text = profileSettings.firstName
        
        lastNameInput.setBorderBottom()
        lastNameInput.text = profileSettings.lastName
        
        ageInput.setBorderBottom()
        ageInput.text = profileSettings.age
        
        cityInput.setBorderBottom()
        cityInput.text = profileSettings.city
        
        if profileSettings.gender == "Male" {
            self.genderCheckBox.selectedSegmentIndex = 0
        } else if (profileSettings.gender == "Female") {
            self.genderCheckBox.selectedSegmentIndex = 1
        }
    }
    
    func saveInformation (sender:UIButton) {
        if genderCheckBox.selectedSegmentIndex == 0 {
            gender = "Male"
        } else {
            gender = "Female"
        }
        
        delegate?.setOptionalInformation(firstName: firstNameInput.text, lastName: lastNameInput.text, gender: gender, age: ageInput.text!, city: cityInput.text)

        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
