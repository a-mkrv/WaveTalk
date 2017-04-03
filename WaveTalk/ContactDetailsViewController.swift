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
    
    var log = Logger()
    var contact = Contact()
    var chatSocket = TCPSocket()
    var myUserName: String?
    var userMessages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //FIXME
        //photoImage.loadImageUsingCacheWithUrlString(urlString: contact.profileImageURL!)
        usernameLabel.text = contact.username
        presenceLabel.text = contact.lastPresenceTime
        statusLabel.text = contact.status
        phoneLabel.text = contact.phoneNumber_or_Email
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        chatSocket = tabBarVC.clientSocket
        
        self.navigationItem.title = usernameLabel.text
        
        loadChatHistoryPerUser()
    }
    
    
    func loadChatHistoryPerUser() {
        if let response = sendRequest(using: chatSocket) {
            
            var bodyOfResponse: String = ""
            let head = response.getHeadOfResponse(with: &bodyOfResponse)
            
            switch(head) {
            case "PERU":
                parseResponseData(response: bodyOfResponse)
                break
            case "EMPT":
                log.debug(msg: "Chat List is empty" as AnyObject)
            default:
                log.error(msg: "Auth Error - Bad response" as AnyObject)
            }
        } else {
            log.error(msg: "Auth Error - Bad request" as AnyObject)
        }
    }
    
    
    private func sendRequest(using client: TCPSocket) -> String? {
        if myUserName != nil {
            
            switch client.client.send(string: "LCPU" + myUserName! + " /s " + contact.username!) {
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
    
    
    //TODO
    //Recode server side
    func parseResponseData(response: String) {
        let res = response
        let messages = res.components(separatedBy: " /pm ")
        
        for message in messages {
            var msg = message.components(separatedBy: " /s ")
            let mess = Message()
            
            mess.from_to = msg[0]
            mess.text = msg[1]
            mess.messageTime = msg[2]
            
            self.userMessages.append(mess)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "startChatWithUser" {
                let destinationController = segue.destination as! ChattingViewController
                destinationController.chatMessages = userMessages
                destinationController.myUserName = myUserName
                destinationController.setUserTitle = contact.username
            
                navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
