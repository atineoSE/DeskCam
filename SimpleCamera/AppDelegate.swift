//
//  AppDelegate.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private var stateController: StateController!
    private var cameraViewController: CameraViewController!
    private weak var configViewController: ConfigViewController?
    
    private var mainStoryboard: NSStoryboard {
        return NSStoryboard(name: "Main", bundle: nil)
    }
    
    private var contentViewController: NSViewController? {
        NSApplication.shared.mainWindow?.windowController?.contentViewController
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        cameraViewController = (mainStoryboard.instantiateController(withIdentifier: "CameraViewController") as! CameraViewController)
        stateController = StateController(delegate: cameraViewController)
        cameraViewController.stateController = stateController
        
        window = NSWindow(contentViewController: cameraViewController)
        window?.makeKeyAndOrderFront(self)
        window?.setup()
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
        self.configViewController = configViewController
    }
    
    @IBAction func didToggleView(_ sender: Any) {
        print("APP DELEGATE: toggled view from menu button or shortcut")
        stateController.toggleState()
        configViewController?.update()
    }
}

