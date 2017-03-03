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
    
    var setUserTitle: String? {
        didSet {
            self.navigationItem.title = setUserTitle
            
            observeMessages()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.senderId = "1"
        self.senderDisplayName = "Mario"
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
                    self.messages.append(JSQMessage(senderId: self.user.id, displayName: self.user.username, text: message.text))
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
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
        sendToFirebase(text)
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
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        return bubbleFactory?.outgoingMessagesBubbleImage(with: .black)
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
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
