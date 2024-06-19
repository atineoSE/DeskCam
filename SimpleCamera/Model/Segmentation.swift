//
//  Segmentation.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 19/6/24.
//

import Foundation

enum Segmentation: String, Codable, CaseIterable, Equatable {
    case none = "None"
    case blur = "Blur"
    case cutout = "Cutout"
}
