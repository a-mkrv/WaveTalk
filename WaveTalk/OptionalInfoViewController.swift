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

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.firstNameInput.resignFirstResponder()
        self.lastNameInput.resignFirstResponder()
        self.ageInput.resignFirstResponder()
        self.cityInput.resignFirstResponder()

        return true
    }
    
    
    func initUI() {
        firstNameInput.setBorderBottom(backColor: UIColor.white)
        if profileSettings.firstName != "-" {
            firstNameInput.text = profileSettings.firstName
        }
        
        lastNameInput.setBorderBottom(backColor: UIColor.white)
        if profileSettings.lastName != "-" {
            lastNameInput.text = profileSettings.lastName
        }
        
        ageInput.setBorderBottom(backColor: UIColor.white)
        if profileSettings.age != "0" {
            ageInput.text = profileSettings.age
        }
        
        cityInput.setBorderBottom(backColor: UIColor.white)
        if profileSettings.city != "Empty" {
            cityInput.text = profileSettings.city
        }
        
        if profileSettings.gender == "Man" {
            self.genderCheckBox.selectedSegmentIndex = 0
        } else if (profileSettings.gender == "Woman") {
            self.genderCheckBox.selectedSegmentIndex = 1
        }
    }
    
    @objc func saveInformation (sender:UIButton) {
        if genderCheckBox.selectedSegmentIndex == 0 {
            gender = "Man"
        } else {
            gender = "Woman"
        }
        
        delegate?.setOptionalInformation(firstName: firstNameInput.text, lastName: lastNameInput.text, gender: gender, age: ageInput.text!, city: cityInput.text)

        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
