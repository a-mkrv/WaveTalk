//
//  Logger.swift
//  WaveTalk
//
//  Created by Anton Makarov on 27.03.17.
//  Copyright © 2017 Anton Makarov. All rights reserved.
//

import Foundation

class Logger {
    func debug(msg: AnyObject, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        let fname = (fileName as NSString).lastPathComponent
        print("\(fname):\(funcName):\(line)", msg)
    }

    func error(msg: AnyObject, line: Int = #line, fileName: String = #file, funcName: String = #function) {
        debug(msg: "ERROR: \(msg)!!" as AnyObject, line: line, fileName: fileName, funcName: funcName)
    }

    func mark(line: Int = #line, fileName: String = #file, funcName: String = #function) {
        debug(msg: "called" as AnyObject, line: line, fileName: fileName, funcName: funcName)
    }
}
