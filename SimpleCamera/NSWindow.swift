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
    
    static func toggleMask() {
        NSWindow.currentWindow?.styleMask = .resizable
    }
    
    static func makeWindowTopMost() {
        NSWindow.currentWindow?.level = .floating
    }
    
    static func setTransparency() {
        NSWindow.currentWindow?.backgroundColor = .clear
    }
}
