//
//  AppDelegate.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import Cocoa
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private var stateController: StateController!
    private var cameraViewController: CameraViewController!
    private let hotkey = HotKey(key: .t, modifiers: [.command, .option, .control])
    
    @IBOutlet weak var toggleViewMenuItem: NSMenuItem!
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
        
        configureKeys()
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
    
    private func configureKeys() {
        hotkey.keyDownHandler = { [weak self] in
            guard let self = self else { return }
            print("APP DELEGATE: hotkey pressed")
            self.didToggleView(self)
        }
    }
}

