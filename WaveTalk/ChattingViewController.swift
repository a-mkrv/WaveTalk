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
    
    var messages = [JSQMessage] ()
    var user = Contact()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var setUserTitle: String? {
        didSet {
            self.navigationItem.title = setUserTitle
            
            observeMessages()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        self.senderDisplayName = "Mario"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let image = UIImage(named: "background.png")
        let imgBackground:UIImageView = UIImageView(frame: self.view.bounds)
        imgBackground.image = image
        imgBackground.contentMode = UIViewContentMode.scaleAspectFill
        imgBackground.clipsToBounds = true
        self.collectionView?.backgroundView = imgBackground
    }
    
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("message").child(messageId)
            messagesRef.observe(.value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : Any] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                if message.chatPartnerId() == self.user.id {
                    if (uid == message.fromId) {
                        self.messages.append(JSQMessage(senderId: uid, displayName: self.user.username, text: message.text))
                    } else {
                        self.messages.append(JSQMessage(senderId: self.user.id, displayName: self.user.username, text: message.text))
                    }
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
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
        //messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
        sendToFirebase(text)
        
        finishSendingMessage()
    }
    
    
    func sendToFirebase(_ text: String!) {
        let ref = FIRDatabase.database().reference().child("message")
        let childRef = ref.childByAutoId()
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let messageTime = String(describing: Date())
        let values = ["text" : text, "toId" : user.id, "fromId" : fromId, "messageTime" : messageTime]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!)
            let messageId = childRef.key
            
            userMessagesRef.updateChildValues([messageId : 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(self.user.id!)
            recipientUserMessagesRef.updateChildValues([messageId : 1])
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
        let message = messages[indexPath.item]
        
        FIRDatabase.database().reference().child("users").child(self.senderId).observeSingleEvent(of: .value, with: {
            (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                if let profileURL = (dictionary["profileImageURL"] as? String) {
                    if message.senderId == self.senderId {
                        cell.avatarImageView.loadImageUsingCacheWithUrlString(urlString: profileURL)
                        
                    } else {
                        cell.avatarImageView.loadImageUsingCacheWithUrlString(urlString: self.user.profileImageURL!)
                    }
                    
                    cell.textView?.textColor = UIColor.black
                    cell.avatarImageView.clipsToBounds = true;
                    cell.avatarImageView.layer.cornerRadius = 15;
                    cell.avatarImageView.isHidden = false;
                }
            }
        }, withCancel: nil)
        
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
