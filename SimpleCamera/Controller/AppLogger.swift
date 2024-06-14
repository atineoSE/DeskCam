//
//  AppLogger.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import os.log

class AppLogger: NSObject {
    static let logger = Logger.init(subsystem: "com.adriantineo.deskCam", category: "General")
    
    static func debug(_ message: String) {
        #if DEBUG
        print(message)
        #else
        logger.notice("DESKCAM: \(message, privacy: .public)") // Notice logs are persisted to disk
        #endif
    }
    
    static func error(_ message: String) {
        #if DEBUG
        print(message)
        #else
        logger.error("DESKCAM: \(message, privacy: .public)")
        #endif
    }
}
