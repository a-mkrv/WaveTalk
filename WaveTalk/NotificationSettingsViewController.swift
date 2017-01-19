//
//  NotificationSettingsViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 18.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

protocol SaveSettingsProtocol {
    func setSound(newValue: Bool)
    func setVibrate(newValue: Bool)
    func setPopUp(newValue: Bool)
    func setAlertTime(newValue: String)
}

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
        
        print("Print - viewDidLoad NotificationSettingsViewController\n")

        alertLabel.text = NotificationSett.Alert
        soundSwitch.setOn(NotificationSett.Sound, animated: true)
        vibrateSwitch.setOn(NotificationSett.Vibrate, animated: true)
        popupSwitch.setOn(NotificationSett.PopUp, animated: true)
        repeatLabel.text = String(NotificationSett.Repeat)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        switch (indexPath.row) {
            case 0:
                let alertController = UIAlertController(title: "All Notifications", message: "Enable or disable for awhile", preferredStyle: .alert)
                let buttonOn = UIAlertAction(title: "On", style: .default, handler: { (action) -> Void in
                    self.setAlertTime(alertTime: "On")
                })
                let buttonOne = UIAlertAction(title: "Disable for an 1 hour", style: .default, handler: { (action) -> Void in
                    self.setAlertTime(alertTime: "Off 1h")
                })
                let buttonThree = UIAlertAction(title: "Disable for an 3 hours", style: .default, handler: { (action) -> Void in
                    self.setAlertTime(alertTime: "Off 3h")
                })
                let buttonTwelve = UIAlertAction(title: "Disable for an 12 hours", style: .default, handler: { (action) -> Void in
                    self.setAlertTime(alertTime: "Off 12h")
                })
                let buttonDay = UIAlertAction(title: "Disable the day", style: .default, handler: { (action) -> Void in
                    self.setAlertTime(alertTime: "Off 1 day")
                })
                let buttonCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                    print("Cancel Button Pressed")
                }

                alertController.addAction(buttonOn)
                alertController.addAction(buttonOne)
                alertController.addAction(buttonThree)
                alertController.addAction(buttonTwelve)
                alertController.addAction(buttonDay)
                alertController.addAction(buttonCancel)
                
                self.present(alertController, animated: true, completion: nil)

            break
            //SOUND
        case 1:
            if (!soundSwitch.isOn) {
                soundSwitch.setOn(true, animated: true)
                delegate?.setSound(newValue: true)
            }
            else {
                soundSwitch.setOn(false, animated: true)
                delegate?.setSound(newValue: false)
            }
            break
            
            //VIBRATE
        case 2:
            if (!vibrateSwitch.isOn) {
                vibrateSwitch.setOn(true, animated: true)
                delegate?.setVibrate(newValue: true)
            }
            else {
                vibrateSwitch.setOn(false, animated: true)
                delegate?.setVibrate(newValue: false)
            }
            break
            
            //POP-UP
        case 3:
            if (!popupSwitch.isOn) {
                popupSwitch.setOn(true, animated: true)
                delegate?.setPopUp(newValue: true)
            }
            else {
                popupSwitch.setOn(false, animated: true)
                delegate?.setPopUp(newValue: false)
            }
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func setAlertTime(alertTime: String) {
        delegate?.setAlertTime(newValue: alertTime)
        defaults.set(alertTime, forKey: "AlertTime")
        alertLabel.text = alertTime
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
