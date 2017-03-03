//
//  DialogListViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 08.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase

class DialogListViewController: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String : Message] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadListOfDialogues()
    }
    
    func loadListOfDialogues() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
    }
    
    
    func observeUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesReference = FIRDatabase.database().reference().child("message").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : Any] {
                    let message = Message()
                    message.setValuesForKeys(dictionary)

                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: {(message1, message2) -> Bool in
                            return message1.messageTime! > message2.messageTime!
                        })
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellDialog", for: indexPath) as! DialogViewCell
        
        let message = messages[indexPath.row]
        cell.message = message

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "openChatView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let dialog = messages[indexPath.row]
                let currentCell = tableView.cellForRow(at: indexPath) as! DialogViewCell
                
                guard let chatPartnerId = dialog.chatPartnerId() else {
                    return
                }
                
                let destinationController = segue.destination as! ChattingViewController
                destinationController.setUserTitle = currentCell.usernameLabel.text
                
                
                let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let dictionary = snapshot.value as? [String : Any] else {
                        return
                    }
                    
                    let user = Contact()
                    user.id = chatPartnerId
                    
                    user.setValuesForKeys(dictionary)
                    destinationController.user = user
                    
                }, withCancel: nil)
            }
            
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    
    func getUserData(chatPartnerId: String) -> Contact {
        let user = Contact()
        
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : Any] else {
                return
            }
            
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            
        }, withCancel: nil)
        
        return user
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
