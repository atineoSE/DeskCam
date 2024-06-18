//
//  CameraViewController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import AppKit
import AVFoundation

class CameraViewController: NSViewController {
    private var cameraLayer: AVCaptureVideoPreviewLayer?
    private var bufferSize: CGSize = .zero
    private let session = AVCaptureSession()
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    @IBOutlet weak var cameraView: NSView!
    weak var stateController: StateController?
    private var currentState: State? {
        didSet {
            view.layer?.setNeedsLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        print("CAMERA VIEW CONTROLLER: set up AV capture session")
        setupLayers()
        print("CAMERA VIEW CONTROLLER: set up layers")
        session.startRunning()
        print("CAMERA VIEW CONTROLLER: started session")
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        updateStateIfNeeded()
    }
    
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
    
    private func configure(mask: Mask, in rect: CGRect) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = rect
        shapeLayer.path = mask.path(in: rect)
        //cameraView.bounds = rect
        cameraView.layer?.mask = shapeLayer
        cameraView.layer?.backgroundColor = .clear
        cameraLayer.frame = rect
        print("CAMERA VIEW CONTROLLER: Updated layer frame to \(rect)")
    }
}

extension CameraViewController: StateControllerDelegate {
    func updateStateIfNeeded() {
        guard 
            let stateController = stateController,
            currentState != stateController.currentState
        else {
            // Nothing to update
            return
        }
        
        guard
            let window = NSWindow.currentWindow,
            let screenSize = NSScreen.screenSize
        else {
            AppLogger.error("CAMERA_VIEW_CONTROLLER: Can't update view")
            return
        }

        let currentState = stateController.currentState
        AppLogger.debug("CAMERA_VIEW_CONTROLLER: Update view with screen size \(screenSize) to state \(currentState)")
        
        let rect = currentState.rect(from: screenSize)
        AppLogger.debug("CAMERA_VIEW_CONTROLLER: got rect \(rect) for state \(currentState)")
        
        window.update(with: rect)
        configure(mask: currentState.mask, in: rect)
        self.currentState = currentState
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // No-op
    }
}
