//
//  State.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation
import AVFoundation

struct State: Codable, Equatable {
    var mask: Mask
    var size: Size
    var position: Position
    var segmentation: Segmentation
}

extension State {
    static let `default` = State(mask: .circle, size: .small, position: .bottomLeft, segmentation: .none)
    
    func rect(from totalSize: CGSize) -> CGRect {
        let size = size.size(over: totalSize)
        let origin = position.origin(targetSize: size, totalSize: totalSize)
        return NSRect(origin: origin, size: size)
    }
}
