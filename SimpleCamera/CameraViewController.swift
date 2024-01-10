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
    private var trackingArea: NSTrackingArea?
    
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
        updateLayers()
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
        self.cameraLayer = cameraLayer
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraView.wantsLayer = true
        cameraView.layer = cameraLayer
    }
    
    private func updateLayers() {
        guard let cameraLayer = cameraLayer else {
            print("CAMERA VIEW CONTROLLER: ERROR - can't update layer")
            return
        }
        // Set layer size
        cameraLayer.frame = cameraView.bounds
        print("Updated layer frame to \(cameraView.bounds)")
        
        // Set video as mirrored
        cameraLayer.connection?.automaticallyAdjustsVideoMirroring = false
        cameraLayer.connection?.isVideoMirrored = true
        
        // Mask view
        setMask(isCircle: true)
        
        registerTrackingAreaIfNeeded()
    }
    
    private func setMask(isCircle: Bool) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = cameraView.bounds
        shapeLayer.path = isCircle ?
            CGPath(ellipseIn: cameraView.bounds, transform: nil) :
            CGPath(rect: cameraView.bounds, transform: nil)
        cameraView.layer?.mask = shapeLayer
        cameraView.layer?.backgroundColor = .clear
    }
}

extension CameraViewController {
    private func registerTrackingAreaIfNeeded() {
        guard trackingArea == nil else {
            return
        }
        print("CAMERA VIEW CONTROLLER: registering tracking area \(cameraView.bounds)")
        let trackingArea = NSTrackingArea(
            rect: cameraView.bounds,
            options: NSTrackingArea.Options(rawValue: NSTrackingArea.Options.mouseEnteredAndExited.rawValue | NSTrackingArea.Options.activeAlways.rawValue),
            owner: self
        )
        self.trackingArea = trackingArea
        cameraView.addTrackingArea(trackingArea)
    }
    
    override func mouseExited(with event: NSEvent) {
        print("CAMERA VIEW CONTROLLER: mouse exited")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.setMask(isCircle: true)
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("CAMERA VIEW CONTROLLER: mouse entered")
        setMask(isCircle: false)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // No-op
    }
}
