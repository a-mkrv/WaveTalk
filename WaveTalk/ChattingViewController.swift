//
//  ChattingViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 13.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase
import FirebaseAuth

class ChattingViewController: JSQMessagesViewController {
    
    var chatSocket = TCPSocket()
    var chatMessages = [Message] ()
    var messages = [JSQMessage] ()
    var user = Contact()
    var rsaCrypt = RSACrypt()
    let userDefaults = UserDefaults.standard

    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var myPublicKey: String?
    var setUserTitle: String? {
        didSet {
            self.navigationItem.title = setUserTitle
            
            observeMessages()
        }
    }
    
    var myUserName: String? {
        didSet {
            self.senderId = "To"
            self.senderDisplayName = myUserName
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        myPublicKey = userDefaults.object(forKey: "myPublicKey") as? String
        
        let tabBarVC = self.tabBarController  as! MainUserTabViewController
        chatSocket = tabBarVC.clientSocket
        
        for users in tabBarVC.contacts {
            if users.username == setUserTitle {
                self.user = users
                break
            }
        }
        
        let image = UIImage(named: "background.png")
        let imgBackground:UIImageView = UIImageView(frame: self.view.bounds)
        imgBackground.image = image
        imgBackground.contentMode = UIViewContentMode.scaleAspectFill
        imgBackground.clipsToBounds = true
        self.collectionView?.backgroundView = imgBackground
    }
    
    
    func observeMessages() {
        for msg in chatMessages {
            messages.append(JSQMessage(senderId: msg.from_to, displayName: senderDisplayName, text: msg.text))
        }
        
        finishReceivingMessage()
    }
    
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.navigationBar.tintColor = .white
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
        
        if text != nil {
            sendToServer(message: text)
        }
        
        finishSendingMessage()
    }
    
    
    func sendToServer(message: String) {
        let myPubKey = (myPublicKey?.components(separatedBy: " "))!
        let userPubKey = (user.pubKey?.components(separatedBy: " "))!
        
        let encryptMsgForMe = rsaCrypt.encodeText(text: message, _e: Int(myPubKey[0])!, _module: Int(myPubKey[1])!)
        
        let encryptMsgForUser = rsaCrypt.encodeText(text: message, _e: Int(userPubKey[0])!, _module: Int(userPubKey[1])!)
        
        var request = "MESG" + myUserName! + " /s " + setUserTitle! + " /s "
        request.append(encryptMsgForMe + " /s " + encryptMsgForUser)
        
        switch chatSocket.client.send(string: request) {
        case .success:
            print("Sent message.")
            break
        case .failure(let error):
            print(error)
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = UIColor.black
        
        //    cell.avatarImageView.clipsToBounds = true;
        //    cell.avatarImageView.layer.cornerRadius = 15;
        //    cell.avatarImageView.isHidden = false;
        
        return cell
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red: 242.0/255, green: 250.0/255, blue: 223.0/255, alpha: 1.0))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(red: 1, green: 1, blue: 1, alpha: 1.0))
    }
}


extension ChattingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let picture = info[UIImagePickerControllerOriginalImage] as? UIImage
        let photo = JSQPhotoMediaItem(image: picture)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}


// Use Firebase
//
//func sendToFirebase(_ text: String!) {
//        let childRef = ref.childByAutoId()
//        let fromId = FIRAuth.auth()?.currentUser?.uid
//        let messageTime = String(describing: Date())
//        let values = ["text" : text, "toId" : user.id, "fromId" : fromId, "messageTime" : messageTime]
//
//        childRef.updateChildValues(values) { (error, ref) in
//            if error != nil {
//                print(error!)
//                return
//            }
//
//            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!)
//            let messageId = childRef.key
//
//            userMessagesRef.updateChildValues([messageId : 1])
//
//            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(self.user.id!)
//            recipientUserMessagesRef.updateChildValues([messageId : 1])
//        }
//}

