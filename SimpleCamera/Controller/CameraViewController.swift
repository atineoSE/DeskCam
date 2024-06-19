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
    private var cameraLayer: AVCaptureVideoPreviewLayer?
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
        setupLayers()
        print("CAMERA VIEW CONTROLLER: set up layers")
        session.startRunning()
        print("CAMERA VIEW CONTROLLER: started session")
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
    
    private func setupLayers() {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.connection?.automaticallyAdjustsVideoMirroring = false
        cameraLayer.connection?.isVideoMirrored = false
        self.cameraLayer = cameraLayer
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.wantsLayer = true
        cameraView.layer = cameraLayer
    }
}

// MARK: - State

extension CameraViewController {
    private func configure(mask: Mask) {
        // Reset view hierarchy
        for subview in cameraView.subviews {
            subview.removeFromSuperview()
        }
        
        guard mask != .segmented else {
            // Add segmentedView to view hierarchy
            cameraView.layer = nil
            cameraView.addSubview(segmentedView)
            segmentedView.frame = cameraView.bounds
            return
        }
        
        cameraView.layer = cameraLayer
        
        // We set the layer rects relative to the container view, cameraView
        let viewRect = cameraView.bounds
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = viewRect
        shapeLayer.path = mask.path(in: viewRect)
        
        // Apply mask
        cameraView.layer?.mask = shapeLayer
        cameraView.layer?.backgroundColor = .clear
        cameraLayer?.frame = viewRect
        
        print("CAMERA VIEW CONTROLLER: Updated layers to \(viewRect)")
        return
    }
    
    private func updateWindow() {
        guard
            let window = NSWindow.currentWindow,
            let screenSize = NSScreen.screenSize,
            let currentState = stateController?.currentState
        else {
            return
        }
        // We set the window rect relative to the screen size
        let windowRect = currentState.rect(from: screenSize)
        window.update(with: windowRect)
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
    private func segment(buffer: CMSampleBuffer) {
        guard 
            let cameraImageBuffer = buffer.imageBuffer,
            let state = stateController?.currentState,
            let screenSize = NSScreen.screenSize,
            let cameraImageSize = cameraImageSize
        else {
            return
        }
        let handler = VNImageRequestHandler(cmSampleBuffer: buffer, options: [:])
        let windowSize = state.size.size(over: screenSize)
        do {
            // Obtain segmentation observation
            try handler.perform([detectPersonSegmentationRequest])
            guard let result = detectPersonSegmentationRequest.results?.first else {
                AppLogger.error("CAMERA_VIEW_CONTROLLER: Failed to obtain a segmentation mask.")
                return
            }
            
            // Get mask from observation
            let maskPixelBuffer = result.pixelBuffer
            let pixelBufferSize = CGSize(
                width: CGFloat(CVPixelBufferGetWidth(maskPixelBuffer)),
                height: CGFloat(CVPixelBufferGetHeight(maskPixelBuffer))
            )
            
            // Transform camera and mask images
            let downsampleTransform = CGAffineTransform.downsampleTransform(initialImageSize: pixelBufferSize, targetImageSize: cameraImageSize)
            let cameraTransform = CGAffineTransform.cameraTransform(initialImageSize: cameraImageSize, targetImageSize: windowSize)
            let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer).transformed(by: downsampleTransform.concatenating(cameraTransform))
            let cameraCIImage = CIImage(cvImageBuffer: cameraImageBuffer).transformed(by: cameraTransform)
            
            let background: CIImage
            if false {
                background = GaussianBlurFilter().filter(cameraCIImage, radius: 5.0) ?? CIImage.empty()
            } else {
                background = CIImage.empty()
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let imageRect = self.cameraView.bounds  // Important to refer to actual view and not to window rect
                
                // Compose camera image and mask
                if
                    let segmentedCIImage = BlendWithMask().filter(cameraCIImage, backgroundImage: background, maskImage: maskCIImage),
                    let segmentedCGImage = ciContext.createCGImage(segmentedCIImage, from: imageRect)
                {
                    segmentedView.image = NSImage(cgImage: segmentedCGImage, size: .zero)
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
        guard stateController?.currentState.mask == .segmented else {
            return
        }
        segment(buffer: sampleBuffer)
    }
}
