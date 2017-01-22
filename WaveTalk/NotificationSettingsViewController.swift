//
//  NotificationSettingsViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 18.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit



class NotificationSettingsViewController: UITableViewController {
    
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var popupSwitch: UISwitch!
    @IBOutlet weak var repeatLabel: UILabel!
    
    var delegate:SaveSettingsProtocol?
    var NotificationSett: NotificationSettings!
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertLabel.text = NotificationSett.Alert
        soundSwitch.setOn(NotificationSett.Sound, animated: true)
        vibrateSwitch.setOn(NotificationSett.Vibrate, animated: true)
        popupSwitch.setOn(NotificationSett.PopUp, animated: true)
        repeatLabel.text = NotificationSett.Repeat
    }
    
    
    // Pressing table cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
            case 0:
                AlertTime()
                break
            case 1:
                soundSwitch(true)
                break
            case 2:
                vibrateSwitch(true)
                break
            case 3:
                popUpSwitch(true)
                break
            case 5:
                RepeatTime()
                break
            default:
                break
            }
        } else {
            if (indexPath.section == 1 && indexPath.row == 0) {
                setDefaultNotifications()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // Pressing Sound Switch
    @IBAction func soundSwitch(_ sender: Any) {
        if (!soundSwitch.isOn) {
            soundSwitch.setOn(true, animated: true)
            delegate?.setSound(newValue: true)
        }
        else {
            soundSwitch.setOn(false, animated: true)
            delegate?.setSound(newValue: false)
        }
    }
    
    
    // Pressing Vibrate Switch
    @IBAction func vibrateSwitch(_ sender: Any) {
        if (!vibrateSwitch.isOn) {
            vibrateSwitch.setOn(true, animated: true)
            delegate?.setVibrate(newValue: true)
        }
        else {
            vibrateSwitch.setOn(false, animated: true)
            delegate?.setVibrate(newValue: false)
        }
    }
    
    
    // Pressing PopUp Switch
    @IBAction func popUpSwitch(_ sender: Any) {
        if (!popupSwitch.isOn) {
            popupSwitch.setOn(true, animated: true)
            delegate?.setPopUp(newValue: true)
        }
        else {
            popupSwitch.setOn(false, animated: true)
            delegate?.setPopUp(newValue: false)
        }
    }
    
    
    // Time of notifications
    func AlertTime() {
        let alertController = UIAlertController(title: "All Notifications", message: "Enable or disable for awhile", preferredStyle: .alert)
        let buttonOn = UIAlertAction(title: "On", style: .default, handler: { (action) -> Void in
            self.setAlertTime(alertTime: "On")
        })
        let buttonOne = UIAlertAction(title: "Disable for an 1 hour", style: .default, handler: { (action) -> Void in
            self.setAlertTime(alertTime: "Off 1 hour")
        })
        let buttonThree = UIAlertAction(title: "Disable for an 3 hours", style: .default, handler: { (action) -> Void in
            self.setAlertTime(alertTime: "Off 3 hours")
        })
        let buttonTwelve = UIAlertAction(title: "Disable for an 12 hours", style: .default, handler: { (action) -> Void in
            self.setAlertTime(alertTime: "Off 12 hours")
        })
        let buttonDay = UIAlertAction(title: "Disable the day", style: .default, handler: { (action) -> Void in
            self.setAlertTime(alertTime: "Off 1 day")
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        
        alertController.addAction(buttonOn)
        alertController.addAction(buttonOne)
        alertController.addAction(buttonThree)
        alertController.addAction(buttonTwelve)
        alertController.addAction(buttonDay)
        alertController.addAction(buttonCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // Reminder time
    func RepeatTime() {
        let repeatController = UIAlertController(title: "Repeat Notifications", message: "", preferredStyle: .alert)
        let buttonOn = UIAlertAction(title: "Off", style: .default, handler: { (action) -> Void in
            self.setRepeatTime(repeatTime: "Off")
        })
        let buttonOne = UIAlertAction(title: "5 minutes", style: .default, handler: { (action) -> Void in
            self.setRepeatTime(repeatTime: "5 minutes")
        })
        let buttonThree = UIAlertAction(title: "15 minutes", style: .default, handler: { (action) -> Void in
            self.setRepeatTime(repeatTime: "15 minutes")
        })
        let buttonTwelve = UIAlertAction(title: "1 hour", style: .default, handler: { (action) -> Void in
            self.setRepeatTime(repeatTime: "1 hour")
        })
        let buttonDay = UIAlertAction(title: "3 hours", style: .default, handler: { (action) -> Void in
            self.setRepeatTime(repeatTime: "3 hours")
        })
        let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        
        repeatController.addAction(buttonOn)
        repeatController.addAction(buttonOne)
        repeatController.addAction(buttonThree)
        repeatController.addAction(buttonTwelve)
        repeatController.addAction(buttonDay)
        repeatController.addAction(buttonCancel)
        
        self.present(repeatController, animated: true, completion: nil)
    }
    
    
    // Time of notifications
    func setAlertTime(alertTime: String) {
        delegate?.setAlertTime(newValue: alertTime)
        alertLabel.text = alertTime
    }
    
    
    // Reminder time
    func setRepeatTime(repeatTime: String) {
        delegate?.setRepeatTime(newValue: repeatTime)
        repeatLabel.text = repeatTime
    }
    
    
    // Setting default notifications
    func setDefaultNotifications() {
        self.setAlertTime(alertTime: "On")
        
        soundSwitch.setOn(true, animated: true)
        delegate?.setSound(newValue: true)
        
        vibrateSwitch.setOn(true, animated: true)
        delegate?.setVibrate(newValue: true)
        
        popupSwitch.setOn(true, animated: true)
        delegate?.setPopUp(newValue: true)
        
        self.setRepeatTime(repeatTime: "15 minutes")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
