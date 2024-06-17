//
//  Mask.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation
import AVFoundation

enum Mask: String, Codable, CaseIterable, Equatable {
    case circle = "Cirle"
    case roundedRectangle = "Rounded rectangle"
    case square = "Square"
    case segmented = "Segmented"
}

extension Mask {
    func path(in rect: CGRect) -> CGPath {
        switch self {
        case .circle:
            return CGPath(ellipseIn: rect, transform: nil)
        case .roundedRectangle:
            return CGPath(
                roundedRect: rect,
                cornerWidth: rect.width / 4.0,
                cornerHeight: rect.height / 4.0,
                transform: nil
            )
        case .square:
            return CGPath(rect: rect, transform: nil)
        case .segmented:
            // TODO
            return CGPath(rect: rect, transform: nil)
        }
    }
}
