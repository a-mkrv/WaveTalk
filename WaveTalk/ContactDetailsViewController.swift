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
    
    var contact = Contact()
    
    override func viewDidLoad() {
        //FIXME
        //photoImage.loadImageUsingCacheWithUrlString(urlString: contact.profileImageURL!)
        usernameLabel.text = contact.username
        presenceLabel.text = contact.lastPresenceTime
        statusLabel.text = contact.status
        phoneLabel.text = contact.phoneNumber_or_Email
        
        self.navigationItem.title = usernameLabel.text
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "startChatWithUser" {
                let destinationController = segue.destination as! ChattingViewController
                destinationController.user = contact
                destinationController.setUserTitle = contact.username
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
