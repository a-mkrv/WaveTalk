//
//  SettingsHeaderViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 10.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class SettingsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    let parameters = ["Privacy", "Notifications", "Calls & Messages", "Media", "General", "", "About", "Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parameters.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellSettings", for: indexPath) as! SettingsViewCell
        cell.nameOfSetting.text = parameters[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SettingsViewCell
       
        print(cell?.nameOfSetting.text ?? "...")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
