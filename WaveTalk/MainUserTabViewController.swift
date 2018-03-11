//
//  MainUserTabViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 12.02.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import SwiftSocket
import UserNotifications

class MainUserTabViewController: UITabBarController {
    
    var myProfile = Contact()
    var contacts = [Contact]()
    var clientSocket = TCPSocket()
    var profileSettings = ProfileSettings()
    
    var readingWorkItem: DispatchWorkItem?
    let readingQueue = DispatchQueue(label: "mainChatQueue")
    
    var isGrantedNotificationAccess:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        }
        )
        
        clientSocket.connect()
        for viewController in self.viewControllers! {
            _ = viewController.view
        }
    }
    
    //Crutches and a bicycle. Use delay
    func startReadingQueue(for client: TCPClient) {
         return
            self.readingWorkItem = DispatchWorkItem {
                guard let item = self.readingWorkItem else { return }
                
                while !item.isCancelled {
                    guard let response = client.read(128, timeout: 1) else { continue }
                    //self.msgNotification(title: String(bytes: response, encoding: .utf8)!)
                    print("DEBUG ", String(bytes: response, encoding: .utf8) ?? "Error")
                }
        }
      
        readingQueue.async(execute: readingWorkItem!)
    }
    
    
    func msgNotification(title: String) {
         if isGrantedNotificationAccess {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = "From MakeAppPie.com"
            content.body = "Notification after 10 seconds - Your pizza is Ready!!"
            
            let request = UNNotificationRequest(
                identifier: "10.second.message",
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
       
    }
    
    
    func finishReadingQueue() {
            (readingWorkItem?.cancel())!
        readingQueue.async(execute: readingWorkItem!)

    }
    
    
    func isCancelQueue() -> Bool {
        return (readingWorkItem?.isCancelled)!
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
