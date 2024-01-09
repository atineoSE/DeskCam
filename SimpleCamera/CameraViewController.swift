//
//  CameraViewController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import AppKit
import AVFoundation

class CameraViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var rootLayer: CALayer?
    private var cameraLayer: AVCaptureVideoPreviewLayer! = nil
    private var bufferSize: CGSize = .zero
    private let session = AVCaptureSession()
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    @IBOutlet weak var cameraView: NSView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVCapture()
        print("CAMERA VIEW CONTROLLER: set up AV capture session")
        setupLayers()
        print("CAMERA VIEW CONTROLLER: set up layers")
        session.startRunning()
        print("CAMERA VIEW CONTROLLER: started session")
    }
    
    // MARK: Setup
    func setupAVCapture() {
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
    
    func setupLayers() {
       // bind root layer
       rootLayer = cameraView.layer
        
        // preview layer
        cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        rootLayer?.addSublayer(cameraLayer)
    }
    
    func updateLayers() {
        cameraLayer.frame = cameraView.bounds
        cameraLayer.connection?.isVideoMirrored = true
    }


    // MARK: Capture
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}


