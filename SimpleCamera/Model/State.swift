//
//  State.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation
import AVFoundation

struct State: Codable, Equatable {
    let mask: Mask
    let size: Size
    let position: Position
}

extension State {
    static let `default` = State(mask: .circle, size: .small, position: .bottomLeft)
    
    func rect(from totalSize: CGSize) -> CGRect {
        let size = size.size(over: totalSize)
        let origin = position.origin(targetSize: size, totalSize: totalSize)
        return NSRect(origin: origin, size: size)
    }
}
