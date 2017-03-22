//
//  RSACrypt.swift
//  WaveTalk
//
//  Created by Anton Makarov on 22.03.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation

extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

class RSACrypt {
    
    var pSimple = 0
    var qSimple = 0
    var d = 0, e = 0, f = 0
    var module = 0
    
    func generationKeys() {
        d = 0
        
        repeat {
            SimpleNumber(n: &pSimple, t: 0)
            SimpleNumber(n: &qSimple, t: 1)
            
            module = pSimple * qSimple
        } while (module < 1500)
        
        f = (pSimple - 1) * (qSimple - 1)
        
        repeat {
            e = Int(arc4random_uniform(150)) + 2
            if (SimpleNumber(n: &e, t: 2) && e < f && (NOD(_p: e, _q: f) == 1)) {
                break
            }
        } while true
        
        while ((d * e) % f != 1  ) {
            d += 1
        }
    }
    
    func SimpleNumber(n: inout Int, t: Int) -> Bool {
        
        if (t==0) {
            n = Int(arc4random_uniform(75))
        } else if (t==1) {
            n = Int(arc4random_uniform(75)) + 75
        } else {
            n = Int(arc4random_uniform(150))
        }
        
        if (n < 2) {
            SimpleNumber(n: &n, t: t)
        }
        
        for i in 2...n {
            if (i * i > n) {
                break
            }
            
            if (n % i == 0) {
                SimpleNumber(n: &n, t: t)
            }
        }
        
        return true
    }
    
    
    func NOD(_p: Int, _q: Int) -> Int {
        var p = _p
        var q = _q
        
        while (p > 0 && q > 0) {
            if (p >= q) {
                p = p % q
            } else {
                q = q % p
            }
        }
        
        return (p | q)
    }
    
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(describing: self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
    
    func encodeText(text: String, _e: Int, _module: Int) -> String {
        
        var tmpText: String = ""
        var encodeText: String = text
        let enterTextSize = text.characters.count
        var encodeInt = Array(repeating: 0, count: enterTextSize)
        var j = 0
        
        for i in encodeText.characters {
            let charUnicode: Int32 = Int32(i.asciiValue!)
            encodeInt[j] = modExp(base: charUnicode, exp: Int32(_e), module: Int32(_module))
            tmpText.append(String((encodeInt[j])) + " ")
            j = j + 1
        }
        
        return tmpText
    }
    
    
    
    func decodeText(text: String, _d: Int, _module: Int) -> String {
        let decryptText = text.components(separatedBy: " ")
        
        let decTextSize = decryptText.count - 1
        var decryptInt = Array(repeating: 0, count: decTextSize)
        var normalText: String = ""
        
        for i in 0..<decTextSize {
            decryptInt[i] = Int(decryptText[i])!
            decryptInt[i] = modExp(base: Int32(decryptInt[i]), exp: Int32(_d), module: Int32(_module))
            normalText.append(String(decryptInt[i]))
        }
        
        return normalText
    }
    
    
    func modExp(base: Int32, exp: Int32, module: Int32) -> Int {
        
        if exp == 0 {
            return 1
        }
        
        var res: Int32 = 0
        
        if (exp % 2 == 0) {
            res = Int32(modExp(base: base, exp: exp/2, module: module))
            return Int((res * res) % module)
        } else {
            res = Int32(modExp(base: base, exp: exp-1, module: module))
            return Int(((base % module) * res) % module)
        }
    }
    
    func getE() -> Int {
        return e
    }
    
    func getModule() -> Int {
        return module
    }
    
    func getD() -> Int {
        return d
    }
    
}
