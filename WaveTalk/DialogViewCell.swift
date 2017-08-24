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
            var youText = ""
            var myMutableString = NSMutableAttributedString()
            let myAppColor = UIColor.getColorBorder()
            
            if message?.from_to == "To" {
                youText = "You: "
            }
            //FIXME
            //Change govnokod =(
            if (message?.text?.characters.count)! > 23 {
                let cellText = youText + (message?.text?.cutString(length: 23))! + "..."
                
                myMutableString = NSMutableAttributedString(string: cellText, attributes: [NSFontAttributeName:UIFont(name: self.lastmessageLabel.font.fontName, size: 17.0)!])
                
                if youText != "" {
                    myMutableString.addAttribute(NSForegroundColorAttributeName, value: myAppColor, range: NSRange(location:0,length:4))
                }
                self.lastmessageLabel.attributedText = myMutableString
                
            } else {
                let cellText = youText + (message?.text)!
                
                myMutableString = NSMutableAttributedString(string: cellText, attributes: [NSFontAttributeName:UIFont(name: self.lastmessageLabel.font.fontName, size: 17.0)!])
                
                if youText != "" {
                    myMutableString.addAttribute(NSForegroundColorAttributeName, value: myAppColor, range: NSRange(location:0,length:4))
                }
                self.lastmessageLabel.attributedText = myMutableString
            }
            
            
            self.timemessageLabel.text = timeFormat(date: (message?.messageTime)!)
            
            setupProfileImage()
        }
    }
    
    
    private func setupProfileImage() {
        let ref = FIRDatabase.database().reference().child("users").child(usernameLabel.text!)
        ref.observe(.value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String : Any] {
                
                if let profileImageURL = dictionary["profileImageURL"] {
                    self.avatarImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL as! String)
                    self.avatarImage.layer.cornerRadius = 30.0
                    self.avatarImage.clipsToBounds = true
                }
            } else {
                self.avatarImage.loadImageUsingCacheWithUrlString(urlString: "#" + self.usernameLabel.text! + " " + "1")
                //print("NO PHOTO " +  self.usernameLabel.text!)
            }
        }, withCancel: nil)
    }
    
    
    func timeFormat(date: String) -> String {
        let currentDate = Date()
        let myDate = date.components(separatedBy: " ")
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd.MM.yy"
        
        let end = formatter.string(from: currentDate)
        let start = myDate[0]
        
        let diff = diffBetweenTwoDates(start: formatter.date(from: start)!, end: formatter.date(from: end)!)
        
        switch diff {
        case 0:
            return myDate[1]
            
        case 1:
            let curHour = Calendar.current.component(.hour, from: Date())
            let msgTime = myDate[1].components(separatedBy: ":")
            
            if Int(curHour) < Int(msgTime[0])! {
                return myDate[1]
            } else {
                return myDate[0]
            }
            
        default:
            return myDate[0]
        }
    }
    
    
    func diffBetweenTwoDates(start: Date, end: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
