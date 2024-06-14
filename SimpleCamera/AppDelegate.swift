//
//  AppDelegate.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let stateController = StateController()
    
    private var mainStoryboard: NSStoryboard {
        return NSStoryboard(name: "Main", bundle: nil)
    }
    
    private var contentViewController: NSViewController? {
        NSApplication.shared.mainWindow?.windowController?.contentViewController
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSWindow.makeWindowTopMost()
        NSWindow.setTransparency()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func showConfigView(_ sender: Any) {
        let configViewController = mainStoryboard.instantiateController(withIdentifier: "ConfigViewController") as! ConfigViewController
        configViewController.stateController = stateController
        contentViewController?.presentAsModalWindow(configViewController)
    }
    
    @IBAction func didToggleView(_ sender: Any) {
        print("APP DELEGATE: toggled view")
        guard let cameraViewController = contentViewController as? CameraViewController else {
            print("MAIN APPLICATION: ERROR - could not find camera view controller")
            return
        }
        cameraViewController.dummyFunc()
    }
}
