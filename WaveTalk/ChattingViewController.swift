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
import BigInt

class ChattingViewController: JSQMessagesViewController {
    
    var chatSocket = TCPSocket()
    var chatMessages = [Message] ()
    var messages = [JSQMessage] ()
    var user = Contact()
    var rsaCrypt = RSACrypt()
    private var pubKey = Key(0, 0)
    private var myPublicKey = Key(0, 0)
    var myPrivateKey = Key(0, 0)

    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    var flag = false
    var myURLImage: String?
    var userImage: UIImage?
    var setUserTitle: String? {
        didSet {
            self.navigationItem.title = setUserTitle
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
        let tabBarVC = self.tabBarController as! MainUserTabViewController
        
        myPublicKey = tabBarVC.myProfile.pubKey!
        myPrivateKey = tabBarVC.myProfile.privateKey!
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let tabBarVC = self.tabBarController as! MainUserTabViewController
        chatSocket = tabBarVC.clientSocket
        
        for users in tabBarVC.contacts {
            if users.username == setUserTitle {
                self.user = users
                break
            }
        }
        
        // FIXME
        if flag {
            return
        }
        
        observeMessages()
        
        let image = UIImage(named: "background.png")
        let imgBackground:UIImageView = UIImageView(frame: self.view.bounds)
        imgBackground.image = image
        imgBackground.contentMode = UIViewContentMode.scaleAspectFill
        imgBackground.clipsToBounds = true
        self.collectionView?.backgroundView = imgBackground
        flag = true
    }

    
    func observeMessages() {
        for msg in chatMessages {
            let cryptMsg = RSACrypt.encrypt(BigUInt(msg.text!)!, key: myPrivateKey)
            msg.text = String(data: cryptMsg.serialize(), encoding: String.Encoding.utf8)
            
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
        let encryptMsgForMe = RSACrypt.encrypt(BigUInt(message.data(using: String.Encoding.utf8)!), key: myPublicKey)
        let encryptMsgForUser = RSACrypt.encrypt(BigUInt(message.data(using: String.Encoding.utf8)!), key: pubKey)
        
        var request = "MESG" + myUserName! + " /s " + setUserTitle! + " /s "
        request.append(String(encryptMsgForMe) + " /s " + String(encryptMsgForUser))
        
        switch chatSocket.client.send(string: request) {
        case .success:
            Logger.debug(msg: "Sent message." as AnyObject)
            break
        case .failure(let error):
            Logger.error(msg: error as AnyObject)
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
        
        let message = messages[indexPath.item]
        
        if message.senderId == "To" {
            if (myURLImage?.characters.count)! > 2 {
                cell.avatarImageView.loadImageUsingCacheWithUrlString(urlString: myURLImage!)
            } else {
                cell.avatarImageView.loadImageUsingCacheWithUrlString(urlString: "#" + myUserName! + " " + myURLImage!)
            }
        } else {
            cell.avatarImageView.image = userImage
        }
        
        cell.avatarImageView.clipsToBounds = true;
        cell.avatarImageView.layer.cornerRadius = 15;
        cell.avatarImageView.isHidden = false;
        
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

