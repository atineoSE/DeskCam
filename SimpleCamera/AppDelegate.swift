//
//  AppDelegate.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var stateController: StateController!
    var cameraViewController: CameraViewController!
    
    private var mainStoryboard: NSStoryboard {
        return NSStoryboard(name: "Main", bundle: nil)
    }
    
    private var contentViewController: NSViewController? {
        NSApplication.shared.mainWindow?.windowController?.contentViewController
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        cameraViewController = (mainStoryboard.instantiateController(withIdentifier: "CameraViewController") as! CameraViewController)
        cameraViewController.windowDelegate = self
        
        stateController = StateController(delegate: self)
        
        window = NSWindow(contentViewController: cameraViewController)
        window?.makeKeyAndOrderFront(self)
        window?.setTransparency()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func showConfigView(_ sender: Any) {
        let configViewController = mainStoryboard.instantiateController(withIdentifier: "ConfigViewController") as! ConfigViewController
        configViewController.stateController = stateController
        cameraViewController.presentAsModalWindow(configViewController)
    }
    
    @IBAction func didToggleView(_ sender: Any) {
        print("APP DELEGATE: toggled view")
        stateController.toggleState()
    }
}

extension AppDelegate: WindowDelegate {
    func toggleStyle() {
        window?.toggleStyle()
    }
    
    func didUpdateState() {
        window?.update(with: stateController.currentState)
    }
}
