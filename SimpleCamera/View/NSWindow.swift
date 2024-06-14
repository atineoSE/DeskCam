//
//  NSWindow.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import AppKit

extension NSWindow {
    static var currentWindow: NSWindow? {
        NSApplication.shared.windows.first
    }
    
    static func toggleStyle() {
        guard let currentWindow = currentWindow else {
            print("NSWINDOW: ERROR - could not find window")
            return
        }
        if currentWindow.styleMask == .borderless {
            currentWindow.styleMask = [.titled, .resizable]
        } else {
            currentWindow.styleMask = .borderless
        }
    }
    
    static func makeWindowTopMost() {
        NSWindow.currentWindow?.level = .floating
    }
    
    static func setTransparency() {
        NSWindow.currentWindow?.backgroundColor = .clear
    }
}
