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
    
    func setup() {
        styleMask = .borderless
        level = .floating
        backgroundColor = .clear
    }
    
    func update(with rect: CGRect) {
        setFrame(rect, display: true)
        AppLogger.debug("NSWINDOW: Updated window frame to \(rect)")
    }
}
