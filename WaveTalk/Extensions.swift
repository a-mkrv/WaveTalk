//
//  Extensions.swift
//  WaveTalk
//
//  Created by Anton Makarov on 28.01.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import BigInt

//////////////////////////////////////////////
// Text Field

extension UITextField {
    func setBorderBottom(_ colorBorder: CGColor = UIColor.getColorBorder(), widthBorder : CGFloat = 1.0, backColor : UIColor = UIColor.clear) {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = backColor
        
        let borderBottom = CALayer()
        let width = widthBorder
        
        borderBottom.borderColor = colorBorder
        borderBottom.frame = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width , height: self.frame.height - 1.0)
        borderBottom.borderWidth = width
        self.layer.addSublayer(borderBottom)
        self.layer.masksToBounds = true
    }
    
    func setRegistrationFieldStyleWith(title: String) {
        let lightGreyColor = UIColor(red: 197/255, green: 205/255, blue: 205/255, alpha: 1.0)
        let darkGreyColor = UIColor(red: 52/255, green: 42/255, blue: 61/255, alpha: 1.0)
        let overcastBlueColor = UIColor(red: 49/255, green: 137/255, blue: 182/255, alpha: 1.0)
        
        let textField = SkyFloatingLabelTextField(frame: CGRect(x: 0, y: 0, width: 215, height: 40))
        textField.placeholder = title
        textField.title = title
        
        textField.tintColor = overcastBlueColor // the color of the blinking cursor
        textField.textColor = darkGreyColor
        textField.lineColor = lightGreyColor
        textField.selectedTitleColor = overcastBlueColor
        textField.selectedLineColor = overcastBlueColor
        
        textField.lineHeight = 1.0 // bottom line height in points
        textField.selectedLineHeight = 1.0
        
        //textField.delegate = CreateAccountViewController()
        self.borderStyle = UITextBorderStyle.none
        self.addSubview(textField)
    }
}

//////////////////////////////////////////////
// String

extension String {
    func getHeadOfResponse(with body: inout String) -> String
    {
        let startIndex = self.characters.index(self.startIndex, offsetBy: 0)
        let endIndex = self.characters.index(self.startIndex, offsetBy: 4)
        let range = startIndex..<endIndex
        
        body = self.substring(from: self.characters.index(self.startIndex, offsetBy: 4))
        
        return self.substring(with: range)
    }
    
    func cutString(length: Int) -> String {
        let startIndex = self.characters.index(self.startIndex, offsetBy: 0)
        let endIndex = self.characters.index(self.startIndex, offsetBy: length)
        let range = startIndex..<endIndex
        
        return self.substring(with: range)
    }
    
    func toKey() -> Key {
        var separateKey = self.components(separatedBy: " ")
        return (modulus: BigUInt(separateKey[0])!, exponent: BigUInt(separateKey[1])!)
    }
}

//////////////////////////////////////////////
// View Controller

extension UIViewController {
    func hideKeyboard() {
        
        //FIXME: Fix hiding the keyboard by pressing the screen
        //Now this is done in part, because lost access to the cells of the table
        //Only by pressing "Return"
        
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer( target:self, action: #selector(UIViewController.dismissKeyboard))
        
        
        //view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

//////////////////////////////////////////////
// Image View

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString : String) {
        
        self.image = nil
        
        // check cache for image
        
        if urlString.characters.first == "#" {
            //urlStr.characters.removeFirst()
            let imageName = urlString.components(separatedBy: " ")
            
            for i in 1..<52 {
                let key = imageName.first! + " " + String(i)
                print(key)
                if let cacheImage = imageCache.object(forKey: key as AnyObject) as? UIImage {
                    self.image = cacheImage
                    return
                }
            }
        } else {
            if let cacheImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
                self.image = cacheImage
                return
            }
        }
        
        // otherwise
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(url: url! as URL)
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            }
            
        }).resume()
        
    }
    
    
    func customImageSettings(borderWidth: CGFloat = 1.5, cornerRadius: CGFloat, color: CGColor = UIColor.getColorBorder()) {
        
        self.clipsToBounds = true
        self.layer.borderColor = color
        self.layer.borderWidth = borderWidth
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}


//////////////////////////////////////////////
// UI Color
extension UIColor {
    
    class func getColorBorder() -> CGColor {
        return UIColor(red: 80/255.0, green: 114/255.0, blue: 153/255.0, alpha: 100.0/100.0).cgColor
    }
    
}
