//
//  MainUserTabViewController.swift
//  WaveTalk
//
//  Created by Anton Makarov on 12.02.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import UIKit
import SwiftSocket

class MainUserTabViewController: UITabBarController {
    
    var myProfile = Contact()
    var contacts = [Contact]()
    var clientSocket = TCPSocket()
    var profileSettings = ProfileSettings()
    
    var readingWorkItem: DispatchWorkItem?
    let readingQueue = DispatchQueue(label: "mainChatQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientSocket.connect()
        //startReadingQueue(for: clientSocket.client)
        
        for viewController in self.viewControllers! {
            _ = viewController.view
        }
    }
    
    
    func startReadingQueue(for client: TCPClient) {
        self.readingWorkItem = DispatchWorkItem {
            guard let item = self.readingWorkItem else { return }
            
            while !item.isCancelled {
                guard let response = client.read(128, timeout: 1) else { continue }
                //print(String(bytes: response, encoding: .utf8) ?? "Error")
            }
        }
        readingQueue.async(execute: readingWorkItem!)
    }

    
    func finishReadingQueue() {
        readingWorkItem?.cancel()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
