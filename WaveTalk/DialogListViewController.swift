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
    
    var dialogUsers = [Contact]()
    var messages = [Message]()
    var messagesDictionary = [String : Message] ()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
        observeMessages()
    }
    
    
    func observeMessages() {
        let ref = FIRDatabase.database().reference().child("message")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : Any] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                //self.messages.append(message)
                
                if let toId = message.toId {
                    self.messagesDictionary[toId] = message
                    
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
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String : Any] {
                let user = Contact()
                user.id = snapshot.key
                
                print(dictionary)
                user.setValuesForKeys(dictionary)
                self.dialogUsers.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }, withCancel: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "openChatView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ChattingViewController
                destinationController.user = dialogUsers[indexPath.row].username
                destinationController.userId = dialogUsers[indexPath.row].id
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            }
        }
    }
}
