//
//  ContactDetailsViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 06.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var avatarImageView: UIImageView!
    var contact = Contact(userName: "", lastMessage: "", lastPresenceTime: "", phoneNumber: "", photoImage: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImageView.image = UIImage(named: contact.photoImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellContactDetails", for: indexPath) as! ContactDetailsViewCell
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Name"
            cell.valueLabel.text = contact.userName
        case 1:
            cell.fieldLabel.text = "Last Presence"
            cell.valueLabel.text = contact.lastPresenceTime
        case 2:
            cell.fieldLabel.text = "Phone"
            cell.valueLabel.text = contact.phoneNumber
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
            
        }
        
        
        return cell
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
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
