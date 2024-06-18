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
    
    @IBOutlet weak var cameraView: NSView!
    weak var stateController: StateController?
    
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
    }
    
    private func setupLayers() {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.connection?.automaticallyAdjustsVideoMirroring = false
        cameraLayer.connection?.isVideoMirrored = true
        self.cameraLayer = cameraLayer
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.wantsLayer = true
        cameraView.layer = cameraLayer
    }
}

// MARK: - State

extension CameraViewController {
    private func configure(mask: Mask) {
        // We set the layer rects relative to the container view, cameraView
        let viewRect = cameraView.bounds
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = viewRect
        shapeLayer.path = mask.path(in: viewRect)
        cameraView.layer?.mask = shapeLayer
        cameraView.layer?.backgroundColor = .clear
        cameraLayer?.frame = viewRect
        print("CAMERA VIEW CONTROLLER: Updated layers to \(viewRect)")
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
        updateWindow()
        if let mask = stateController?.currentState.mask {
            configure(mask: mask)
        }
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
    
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // No-op
    }
}
