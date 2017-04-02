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
    var messagesDictionary = [String : [Message]] ()
    var dialogSocket = TCPSocket()
    var log = Logger()
    var myUserName: String?
    
    
    
    let byValue = {
        (elem1:(key: String, val: String), elem2:(key: String, val: String))->Bool in
        if elem1.val < elem2.val {
            return true
        } else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        dialogSocket = tabBarVC.clientSocket
        myUserName = tabBarVC.myProfile.username
        
        loadListOfDialogues()
    }
    
    func loadListOfDialogues() {
        //messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
    }
    
    
    func observeUserMessages() {
        
        if let response = sendRequest(using: dialogSocket) {
            
            var bodyOfResponse: String = ""
            let head = response.getHeadOfResponse(with: &bodyOfResponse)
            
            switch(head) {
            case "EXST":
                parseResponseData(response: bodyOfResponse)
                break
            case "EMPT":
                log.debug(msg: "Dialog List is empty" as AnyObject)
            default:
                log.error(msg: "Auth Error - Bad response" as AnyObject)
            }
        } else {
            log.error(msg: "Auth Error - Bad request" as AnyObject)
        }
    }
    
    
    private func sendRequest(using client: TCPSocket) -> String? {
        if myUserName != nil {
            
            switch client.client.send(string: "LCHT" + myUserName!) {
            case .success:
                return client.readResponse()
            case .failure(let error):
                log.error(msg: error as AnyObject)
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    /// Parse response chat history
    func parseResponseData(response: String) {
        let res = response
        var dialogs = res.components(separatedBy: " //s ")
        dialogs.remove(at: 0)
        
        for dialog in dialogs {
            if dialog.range(of:" /pm ") != nil {
                let mess = Message()
                var userMessages = [Message]()
                var messages = dialog.components(separatedBy: " /pm ")
                let userName = messages[0]
                
                messages.remove(at: 0)
                
                for message in messages {
                    var msg = message.components(separatedBy: " /s ")
                    mess.from_to = msg[0]
                    mess.text = msg[1]
                    mess.messageTime = msg[2]
                }
                
                userMessages.append(mess)
                messagesDictionary[userName] = userMessages
                
            } else {
                messagesDictionary[dialog] = [Message]()
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDictionary.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellDialog", for: indexPath) as! DialogViewCell
        
        let message = Array(messagesDictionary.values)[indexPath.row]
        cell.message = message.last
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if segue.identifier == "openChatView" {
        //            if let indexPath = tableView.indexPathForSelectedRow {
        //                let dialog = Array(messagesDictionary.values)[indexPath.row]
        //                let currentCell = tableView.cellForRow(at: indexPath) as! DialogViewCell
        //
        //                guard let chatPartnerId = dialog.chatPartnerId() else {
        //                    return
        //                }
        //
        //                let destinationController = segue.destination as! ChattingViewController
        //                destinationController.setUserTitle = currentCell.usernameLabel.text
        //
        //
        //                let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        //                ref.observeSingleEvent(of: .value, with: { (snapshot) in
        //
        //                    guard let dictionary = snapshot.value as? [String : Any] else {
        //                        return
        //                    }
        //
        //                    let user = Contact()
        //                    user.id = chatPartnerId
        //
        //                    user.setValuesForKeys(dictionary)
        //                    destinationController.user = user
        //
        //                }, withCancel: nil)
        //            }
        //
        //            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //        }
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


// Use Firebase
//
//let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
//ref.observe(.childAdded, with: { (snapshot) in
//    let messageId = snapshot.key
//    let messagesReference = FIRDatabase.database().reference().child("message").child(messageId)
//
//    messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
//
//        if let dictionary = snapshot.value as? [String : Any] {
//            let message = Message()
//            message.setValuesForKeys(dictionary)
//
//            if let chatPartnerId = message.chatPartnerId() {
//                self.messagesDictionary[chatPartnerId] = message
//                self.messages = Array(self.messagesDictionary.values)
//                self.messages.sort(by: {(message1, message2) -> Bool in
//                    return message1.messageTime! > message2.messageTime!
//                })
//            }
//
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//
//    }, withCancel: nil)
//}, withCancel: nil)
