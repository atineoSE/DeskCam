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

class ColorMatrix {
    private let filter = CIFilter(name: "CIColorMatrix")!
    init() {}
    func filter(
        _ inputImage: CIImage,
        rVector: CIVector = .init(x: 1.0, y: 0.0, z: 0.0, w: 0.0),
        gVector: CIVector = .init(x: 0.0, y: 1.0, z: 0.0, w: 0.0),
        bVector: CIVector = .init(x: 0.0, y: 0.0, z: 1.0, w: 0.0),
        aVector: CIVector = .init(x: 0.0, y: 0.0, z: 0.0, w: 1.0),
        biasVector: CIVector = .init(x: 0.0, y: 0.0, z: 0.0, w: 0.0)
    ) -> CIImage? {
        filter.setValue(rVector, forKey: "inputRVector")
        filter.setValue(gVector, forKey: "inputGVector")
        filter.setValue(bVector, forKey: "inputBVector")
        filter.setValue(aVector, forKey: "inputAVector")
        filter.setValue(biasVector, forKey: "inputBiasVector")
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
}
