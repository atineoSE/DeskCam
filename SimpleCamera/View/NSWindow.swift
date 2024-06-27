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
        hasShadow = false
    }
    
    func animationResizeTime(_ newFrame: NSRect) -> TimeInterval {
        return 5.0
    }
    
    func update(with rect: CGRect, shouldAnimate: Bool) {
        setFrame(rect, display: true, animate: shouldAnimate)
        AppLogger.debug("NSWINDOW: Update window frame to \(rect)")
    }
}
