//
//  CGAffineTransform.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 19/6/24.
//

import Vision

extension CGAffineTransform {
    static func cameraTransform(state: State, cameraImageSize: CGSize, screenSize: CGSize) -> Self {
        let windowSize = state.size.size(over: screenSize)
        
        // Normalize camera image to window size
        let scaleFactor =  windowSize.height / cameraImageSize.height
        
        // Offset image to center in window
        let xOffset = ((cameraImageSize.width * scaleFactor) - windowSize.width) / 2.0
        
        return CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            .concatenating(CGAffineTransform(translationX: -xOffset, y: 0.0))
    }
}
