//
//  NSWindow.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import AppKit

extension NSWindow {
    private var screenSize: CGSize? {
        NSScreen
            .screens
            .sorted(by: { $0.visibleFrame.size.width < $1.visibleFrame.size.width } )
            .first?
            .visibleFrame
            .size
    }
    
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
    
    func update(with state: State) {
        guard let screenSize = screenSize else {
            AppLogger.error("NSWINDOW: Could not find current screen")
            return
        }
        let size = state.size.getSize(over: screenSize)
        let origin = state.position.getOrigin(targetSize: size, totalSize: screenSize)
        let rect = NSRect(origin: origin, size: size)
        setFrame(rect, display: true)
        AppLogger.debug("NSWINDOW: Updated window frame to \(rect) inside \(screenSize)")
    }
}
