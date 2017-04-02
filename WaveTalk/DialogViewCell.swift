//
//  DialogViewCell.swift
//  WaveTalk
//
//  Created by Anton Makarov on 08.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import Firebase

class DialogViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastmessageLabel: UILabel!
    @IBOutlet weak var timemessageLabel: UILabel!
    
    var dialogUsers = [Contact]()
    
    var message: Message? {
        didSet {
            self.lastmessageLabel.text = message?.text
            //self.timemessageLabel.text = timeFormat(date: (message?.messageTime)!)
            
            setupNameAndProfileImage()
        }
    }
    
    private func setupNameAndProfileImage() {
//        if let id = message?.chatPartnerId() {
//            let ref = FIRDatabase.database().reference().child("users").child(id)
//            ref.observe(.value, with: {(snapshot) in
//                if let dictionary = snapshot.value as? [String : Any] {
//                    
//                    self.usernameLabel.text = dictionary["username"] as? String
//                    if let profileImageURL = dictionary["profileImageURL"] {
//                        self.avatarImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL as! String)
//                        self.avatarImage.layer.cornerRadius = 30.0
//                        self.avatarImage.clipsToBounds = true
//                    }
//                }
//            }, withCancel: nil)
//        }
    }
    
    
    func timeFormat(date: String) -> String {
        let myDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let date = dateFormatter.date(from:myDate)!
        dateFormatter.dateFormat = "hh:mm:ss a"
        let dateString = dateFormatter.string(from:date)
        
        return dateString
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
