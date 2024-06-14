//
//  State.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

struct State: Codable {
    let mask: Mask
    let size: Size
    let position: Position
}

extension State {
    static let `default` = State(mask: .circle, size: .small, position: .bottomLeft)
}
