//
//  tmpViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 07.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UITableViewController {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var presenceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    
    var contact = Contact(userName: "", lastMessage: "", lastPresenceTime: "", phoneNumber: "", photoImage: "")
    
    override func viewDidLoad() {
        photoImage.image = UIImage(named: contact.photoImage)
        usernameLabel.text = contact.userName
        presenceLabel.text = contact.lastPresenceTime
        phoneLabel.text = contact.phoneNumber
        
        self.navigationItem.title = usernameLabel.text
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
