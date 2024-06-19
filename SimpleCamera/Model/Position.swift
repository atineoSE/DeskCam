//
//  Position.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

enum Position: String, Codable, CaseIterable, Equatable {
    case topLeft = "Top left"
    case topRight = "Top right"
    case center = "Center"
    case bottomCenter = "Bottom center"
    case bottomLeft = "Bottom left"
    case bottomRight = "Bottom right"
}

extension Position {
    func origin(targetSize: CGSize, totalSize: CGSize) -> CGPoint {
        let margin = totalSize.height / 50.0
        switch self {
        case .bottomLeft:
            return CGPoint(
                x: margin,
                y: margin
            )
        case .bottomRight:
            return CGPoint(
                x: totalSize.width - targetSize.width - margin,
                y: margin
            )
        case .center:
            return CGPoint(
                x: (totalSize.width / 2.0) - (targetSize.width / 2.0),
                y: (totalSize.height / 2.0) - (targetSize.height / 2.0)
            )
        case .bottomCenter:
            return CGPoint(
                x: (totalSize.width - targetSize.width) / 2.0,
                y: 0.0
            )
        case .topLeft:
            return CGPoint(
                x: margin,
                y: totalSize.height - targetSize.height - margin
            )
        case .topRight:
            return CGPoint(
                x: totalSize.width - targetSize.width - margin,
                y: totalSize.height - targetSize.height - margin
            )
        }
    }
}
