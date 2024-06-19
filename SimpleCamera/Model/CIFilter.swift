//
//  CIFilter.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 19/6/24.
//


import CoreImage

class BlendWithMask {
    private let filter = CIFilter(name: "CIBlendWithMask")!
    init() {}
    func filter(_ inputImage: CIImage, backgroundImage: CIImage, maskImage: CIImage) -> CIImage? {
        filter.setValue(maskImage, forKey: "inputMaskImage")
        filter.setValue(backgroundImage, forKey: "inputBackgroundImage")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
}

class GaussianBlurFilter {
    private let filter = CIFilter(name: "CIGaussianBlur")!
    init() {}
    func filter(_ inputImage: CIImage, radius: Float = 1.0) -> CIImage? {
        filter.setValue(radius, forKey: "inputRadius")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
}
