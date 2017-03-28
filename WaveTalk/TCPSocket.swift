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
    var log = Logger()
    
    func connect(host: String = "127.0.0.1", port: String = "55155") {
        client = TCPClient(address: host, port: Int32(port)!)
        
        if (client.connect(timeout: 1).isSuccess) {
            log.debug(msg: "Successful connection" as AnyObject)
        } else {
            log.error(msg: "Connection error" as AnyObject)
        }
    }
    
    
    func disconnect() {
        log.debug(msg: "Disconnect" as AnyObject)
        
        client.close()
    }
    
    
    func isConnectState() -> Bool {
       return true
    }
    
    
    func readResponse() -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
}
