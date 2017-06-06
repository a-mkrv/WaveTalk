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
    var myURLImage: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //(self.tabBarController  as! MainUserTabViewController).finishReadingQueue()

        let tabBarVC = self.tabBarController  as! MainUserTabViewController

        dialogSocket = tabBarVC.clientSocket
        myUserName = tabBarVC.myProfile.username
        myURLImage = tabBarVC.myProfile.profileImageURL
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print((self.tabBarController  as! MainUserTabViewController).isCancelQueue())
        
        (self.tabBarController  as! MainUserTabViewController).finishReadingQueue()
        print((self.tabBarController  as! MainUserTabViewController).isCancelQueue())

        loadListOfDialogues()
        
        self.tableView.backgroundColor = UIColor(red: 251/255.0, green: 250/255.0, blue: 252/255.0, alpha: 100.0/100.0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    func loadListOfDialogues() {
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
                var userMessages = [Message]()
                var messages = dialog.components(separatedBy: " /pm ")
                let userName = messages[0]
                messages.remove(at: 0)
                
                for message in messages {
                    var msg = message.components(separatedBy: " /s ")
                    let mess = Message()
                    
                    mess.from_to = msg[0]
                    mess.text = msg[1]
                    mess.messageTime = msg[2]
                    
                    userMessages.append(mess)
                }
                
                messagesDictionary[userName] = userMessages
            } else {
                messagesDictionary[dialog] = [Message]()
            }
            
            tableView.reloadData()
        }
        
        //FIXME: Sort dictionary
        //messagesDictionary.sorted(by: { ($0.value.last?.messageTime!)! < ($1.value.last?.messageTime!)!})
        //let itemResult = messagesDictionary.sorted { (chat1, chat2) -> Bool in
        //      return (chat1.value.last?.messageTime!)! > (chat2.value.last?.messageTime)!
        //}
        //messagesDictionary = itemResult as Dictionary[String: [Message]]
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesDictionary.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellDialog", for: indexPath) as! DialogViewCell
        
        let dialog = Array(messagesDictionary)[indexPath.row]
        cell.usernameLabel.text = dialog.key
        cell.message = dialog.value.last
        
        cell.backgroundColor = UIColor(white: 1, alpha: 0.9)

        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openChatView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let currentCell = tableView.cellForRow(at: indexPath) as! DialogViewCell
                let dialogName = currentCell.usernameLabel.text!
                let destinationController = segue.destination as! ChattingViewController
                
                destinationController.myURLImage = self.myURLImage
                destinationController.userImage = currentCell.avatarImage.image
                destinationController.chatMessages = messagesDictionary[dialogName]!
                destinationController.myUserName = myUserName
                destinationController.setUserTitle = dialogName
            }
            
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
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
