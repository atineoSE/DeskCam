//
//  NSWindow.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import AppKit

extension NSWindow {
    func toggleStyle() {
        if styleMask == .borderless {
            styleMask = [.titled, .resizable]
        } else {
            styleMask = .borderless
        }
    }
    
    func makeWindowTopMost() {
        level = .floating
    }
    
    func setTransparency() {
        backgroundColor = .clear
    }
}
