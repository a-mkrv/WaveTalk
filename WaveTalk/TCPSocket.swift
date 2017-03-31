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
        var data = [UInt8]()
        
        while true {
            guard let buff = client.read(64) else { return nil }
            
            data = data + buff
            
            if buff.count < 64 {
                break
            }
        }
        
        return String(bytes: data, encoding: .utf8)
    }
}
