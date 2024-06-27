//
//  CameraViewController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import AppKit
import AVFoundation
import Vision

class CameraViewController: NSViewController {
    private var bufferSize: CGSize = .zero
    private let session = AVCaptureSession()
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    private let ciContext = CIContext()
    private var segmentedView = NSImageView()
    private var cameraImageSize: CGSize?
    private var cameraTransform: CGAffineTransform?
    
    @IBOutlet weak var cameraView: NSView!
    weak var stateController: StateController?
    
    private lazy var detectPersonSegmentationRequest: VNGeneratePersonSegmentationRequest = {
        let request = VNGeneratePersonSegmentationRequest()
        request.revision = VNGeneratePersonSegmentationRequestRevision1
        request.qualityLevel = .balanced
        return request
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        print("CAMERA VIEW CONTROLLER: set up AV capture session")
        //setupLayers()
        //print("CAMERA VIEW CONTROLLER: set up layers")
        session.startRunning()
        print("CAMERA VIEW CONTROLLER: started session")
        
        cameraView.addSubview(segmentedView)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        refresh()
    }
}

// MARK: - Setup

extension CameraViewController {
    private func setupAVCapture() {
        var deviceInput: AVCaptureDeviceInput!
        
        // Select a video device, make an input
        let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front).devices.first
        do {
            deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Add a video input
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        
        // Add a video data output
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = nil
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        
        do {
            try videoDevice!.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        
        session.commitConfiguration()
        
        if let dimensions = videoDevice?.activeFormat.formatDescription.dimensions {
            cameraImageSize = CGSize(width: Int(dimensions.width), height: Int(dimensions.height))
        }
    }
}

// MARK: - State

extension CameraViewController {
    private func configure(mask: Mask) {
        // Set rect relative to the container view, cameraView
        let viewRect = cameraView.bounds
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = viewRect
        shapeLayer.path = mask.path(in: viewRect)
        shapeLayer.borderColor = .clear
        
        // Apply window mask
        cameraView.layer?.mask = shapeLayer
        
        // Update segmented view
        segmentedView.frame = viewRect
        cameraView.setNeedsDisplay(viewRect)
        cameraView.displayIfNeeded()
        
        print("CAMERA VIEW CONTROLLER: Updated frames to \(viewRect)")
    }
    
    private func updateWindow() {
        guard
            let window = NSWindow.currentWindow,
            let screenSize = NSScreen.screenSize,
            let stateController = stateController
        else {
            return
        }
        
        let currentState = stateController.currentState
        let windowRect = currentState.rect(from: screenSize) // Set the window rect relative to the screen size
        window.update(with: windowRect, shouldAnimate: stateController.shouldAnimateTransition)
        AppLogger.debug("CAMERA_VIEW_CONTROLLER: Updated window with screen size \(screenSize) to \(windowRect) (state: \(currentState))")
    }
    
    private func refresh() {
        AppLogger.debug("CAMERA_VIEW_CONTROLLER: Refresh")
        guard let currentState = stateController?.currentState else {
            return
        }
        updateWindow()
        configure(mask: currentState.mask)
    }
}

// MARK: - StateControllerDelegate

extension CameraViewController: StateControllerDelegate {
    func updateState() {
        refresh()
    }
}

// MARK: - Vision

extension CameraViewController {
    private var cameraToWindowTransform: CGAffineTransform? {
        guard
            let cameraImageSize = cameraImageSize,
            let currentState = stateController?.currentState,
            let screenSize = NSScreen.screenSize
        else {
            return nil
        }
        let windowSize = currentState.size.size(over: screenSize)
        return CGAffineTransform.cameraTransform(initialImageSize: cameraImageSize, targetImageSize: windowSize)
    }
    
    private func observationToCameraTransform(buffer: CVPixelBuffer) -> CGAffineTransform? {
        guard let cameraImageSize = cameraImageSize else {
            return nil
        }
        let pixelBufferSize = CGSize(
            width: CGFloat(CVPixelBufferGetWidth(buffer)),
            height: CGFloat(CVPixelBufferGetHeight(buffer))
        )
        return CGAffineTransform.downsampleTransform(initialImageSize: pixelBufferSize, targetImageSize: cameraImageSize)
    }
    
    private func segment(buffer: CMSampleBuffer) {
        guard 
            let cameraImageBuffer = buffer.imageBuffer,
            let state = stateController?.currentState,
            let cameraToWindowTransform = cameraToWindowTransform
        else {
            return
        }
        
        // No segmentation to do, just return the image
        guard state.segmentation != .none else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                let imageRect = self.cameraView.bounds  // Important to refer to actual view and not to window rect
                let cameraCIImage = CIImage(cvImageBuffer: cameraImageBuffer).transformed(by: cameraToWindowTransform)
                if let cameraCGImage = ciContext.createCGImage(cameraCIImage, from: imageRect) {
                    segmentedView.image = NSImage(cgImage: cameraCGImage, size: .zero)
                    cameraView.setNeedsDisplay(imageRect)
                    cameraView.displayIfNeeded()
                }
            }
            return
        }
        
        // Perform segmentation
        let handler = VNImageRequestHandler(cmSampleBuffer: buffer, options: [:])
        do {
            // Obtain segmentation observation
            try handler.perform([detectPersonSegmentationRequest])
            guard let result = detectPersonSegmentationRequest.results?.first else {
                AppLogger.error("CAMERA_VIEW_CONTROLLER: Failed to obtain a segmentation mask.")
                return
            }
    
            // Transform mask image
            let maskPixelBuffer = result.pixelBuffer
            guard let downsampleTransform = observationToCameraTransform(buffer: maskPixelBuffer) else {
                return
            }
            let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer).transformed(by: downsampleTransform)
            
            
            // Get camera image
            let cameraCIImage = CIImage(cvImageBuffer: cameraImageBuffer)
            
            // Get background
            let background: CIImage
            if state.segmentation == .blur {
                background = GaussianBlurFilter().filter(cameraCIImage, radius: 5.0) ?? CIImage.empty()
            } else {
                // Cutout
                background = CIImage.empty()
            }
            
            // Apply mask at camera coordinates, then transform to window coordinates
            guard let segmentedCIImage = BlendWithMask().filter(cameraCIImage, backgroundImage: background, maskImage: maskCIImage) else {
                AppLogger.error("CAMERA_VIEW_CONTROLLER: Failed to apply blend with mask filter")
                return
            }
            let scaledSegmentedCIImage = segmentedCIImage.transformed(by: cameraToWindowTransform)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let imageRect = self.cameraView.bounds  // Important to refer to actual view and not to window rect
                if let segmentedCGImage = ciContext.createCGImage(scaledSegmentedCIImage, from: imageRect) {
                    segmentedView.image = NSImage(cgImage: segmentedCGImage, size: .zero)
                    cameraView.setNeedsDisplay(imageRect)
                    cameraView.displayIfNeeded()
                }
            }
        } catch let error as NSError {
            AppLogger.error("CAMERA_VIEW_CONTROLLER: Failed to perform segmentation request with error \(error.localizedDescription)")
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        segment(buffer: sampleBuffer)
    }
}
