//
//  TCPSocket.swift
//  WaveTalk
//
//  Created by Anton Makarov on 25.03.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation
import SwiftSocket

class TCPSocket : AnyObject {
    var client: TCPClient!

    func connect(host: String = "127.0.0.1", port: String = "55155") {
        client = TCPClient(address: host, port: Int32(port)!)
        
        if (client.connect(timeout: 1).isSuccess) {
            print("Successful connection")
        } else {
            print("Connection error")
        }
    }
    
    
    func disconnect() {
        client.close()
    }
    
    
    func readResponse() -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
}
