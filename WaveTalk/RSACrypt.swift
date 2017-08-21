//
//  RSACrypt.swift
//  WaveTalk
//
//  Created by Anton Makarov on 22.03.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation
import BigInt

typealias Key = (modulus: BigUInt, exponent: BigUInt)

class RSACrypt {
    
    static var publicKey: Key!
    static var privateKey: Key!

    static let sharedRSA = RSACrypt()
    static var isGenerate = false
    
    static func generatePrime(kSize: Int) -> BigUInt {
        while true {
            var random = BigUInt.randomInteger(withExactWidth: kSize)
            random |= BigUInt(1)
            
            if random.isPrime() {
                return random
            }
        }
    }
    
    
    static func generationKeys() {
        if isGenerate {
            return
        }
        
        let p = self.generatePrime(kSize: 256)
        let q = self.generatePrime(kSize: 256)
        
        let n = p * q
        
        let e: BigUInt = 65537
        let phi = (p - 1) * (q - 1)
        let d = e.inverse(phi)!
        
        self.publicKey = (n, e)
        self.privateKey = (n, d)
        
        isGenerate = true
    }
    
    
    static func encrypt(_ message: BigUInt, key: Key) -> BigUInt {
        return modularExponentRToLBinary(base: message, exponent: key.exponent, modulus: key.modulus)
    }
    
    
    static func modularExponentRToLBinary(base: BigUInt, exponent: BigUInt, modulus: BigUInt) -> BigUInt {
        if modulus == 1 { return 0 }
        
        var result = BigUInt(1)
        var b = base % modulus
        var e = exponent
        
        while e > 0 {
            if e[0] & 1 == 1 {
                result = (result * b) % modulus
            }
            e >>= 1
            b = (b * b) % modulus
        }
        return result
    }
}
