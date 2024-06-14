//
//  Position.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

enum Position: String, Codable, CaseIterable {
    case topLeft = "Top left"
    case topRight = "Top right"
    case center = "Center"
    case bottomLeft = "Bottom left"
    case bottomRight = "Bottom right"
}
