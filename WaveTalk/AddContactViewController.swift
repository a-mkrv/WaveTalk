//
//  AddContactViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 12.02.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import SCLAlertView
//import FirebaseDatabase

class AddContactViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var requestField: UITextField!
    
    var delegate: UserListProtocol?
    var searchSocket = TCPSocket()
    var existContacts: [String] = []
    var myUserName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestField.delegate = self
        requestField.setBorderBottom()
    }
    
    
    @IBAction func addContact(_ sender: Any) {
        (self.tabBarController  as! MainUserTabViewController).finishReadingQueue()

        if let existUser = self.requestField.text {
            if existUser == myUserName {
                SCLAlertView().showTitle("Error", subTitle: "\nYou can not add yourself\n", style: .error, closeButtonTitle: "Look for another", colorStyle: 0x4196BE, animationStyle: .topToBottom)
                SCLAlertView().showTitle( "Error", subTitle: "\nYou can not add yourself\n", style: .error, closeButtonTitle: "Look for another", colorStyle: 0x4196BE)
                return
            }
            
            for user in existContacts {
                if user == existUser {
                    //( "Error", subTitle: "\nUser is already added\n", duration: 0.0, completeText: "Look for another", style: .error, colorStyle: 0x4196BE)
                    return
                }
            }
        } else {
            print("Error - search field is empty")
            return
        }
        
        
        if let response = sendRequest(using: searchSocket) {
            
            var bodyOfResponse: String = ""
            let head = response.getHeadOfResponse(with: &bodyOfResponse)
            
            switch(head) {
            case "FNDN": //Find Negative
               // SCLAlertView().showTitle( "Error", subTitle: "\nUser is not found\n", duration: 0.0, completeText: "Look for another", style: .error, colorStyle: 0x4196BE)
                break
                
            case "FNDP": //Find Positive
                let userData = bodyOfResponse.components(separatedBy: " /s ")
                let user = Contact()
                
                user.username = self.requestField.text
                user.pubKey = userData[1].toKey()
                user.lastPresenceTime = userData[2]
                user.phoneNumber_or_Email = userData[3]
                user.status = userData[4]
                
                delegate?.addNewContact(contact: user)
                _ = navigationController?.popViewController(animated: true)
                break
                
            default:
                print("Auth Error - Bad response")
            }
        } else {
            print("Auth Error - Bad request")
        }
        
        (self.tabBarController  as! MainUserTabViewController).startReadingQueue(for: searchSocket.client)
    }
    
    
    private func sendRequest(using client: TCPSocket) -> String? {
        
        guard let searchUser = self.requestField.text else {
            return nil
        }
        
        var request = "FIND"
        request.append(searchUser + " /s " + myUserName)
        
        switch client.client.send(string: request) {
        case .success:
            return client.readResponse()
        case .failure(let error):
            print(error)
            return nil
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.requestField.resignFirstResponder()
        
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//Use Firebase
//
//let rootRef = FIRDatabase.database().reference()
//let email = requestField.text

//rootRef.child("users").child(user.uid).setValue(["username": email])

//        rootRef.child("users").queryEqual(toValue: email, childKey: "users").observe(.value, with: { snapshot in
//            if snapshot.exists() {
//                print("user exists")
//
//            } else if !snapshot.exists(){
//                print("user doesn't exist")
//
//            }
//        })
