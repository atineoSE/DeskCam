//
//  CGAffineTransform.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 19/6/24.
//

import Vision

extension CGAffineTransform {
    static func transform(initialImageSize: CGSize, targetImageSize: CGSize) -> Self {
        let scaleFactor = targetImageSize.height / initialImageSize.height
        let xOffset = ((initialImageSize.width * scaleFactor) - targetImageSize.width) / 2.0
        return CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            .concatenating(CGAffineTransform(translationX: -xOffset, y: 0.0))
    }
}
