//
//  NSScreen.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 17/6/24.
//

import Foundation
import AppKit

extension NSScreen {
    static var screenSize: CGSize? {
        NSScreen
            .screens
            .sorted(by: { $0.visibleFrame.size.width < $1.visibleFrame.size.width } )
            .first?
            .visibleFrame
            .size
    }
}
