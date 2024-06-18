//
//  Size.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

enum Size: String, Codable, CaseIterable, Equatable {
    case small = "Small"
    case medium = "Medium"
    case full = "Full screen"
}

extension Size {
    func size(over totalSize: CGSize) -> CGSize {
        let baseHeight = totalSize.height
        switch self {
        case .small:
            return CGSize(width: floor(baseHeight/4.0), height: floor(baseHeight/4.0))
        case .medium:
            return CGSize(width: floor(baseHeight/3.0), height: floor(baseHeight/3.0))
        case .full:
            return CGSize(width: totalSize.width, height: baseHeight)
        }
    }
}
