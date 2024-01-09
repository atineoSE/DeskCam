//
//  NSWindow.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import AppKit

extension NSWindow {
    static func toggleMask() {
        guard let window = NSApplication.shared.windows.first else {
            print("NSWindow: can't find window")
            return
        }
        if window.styleMask != .borderless {
            window.styleMask = .borderless
        } else {
            window.styleMask = .titled
        }
    }
}
