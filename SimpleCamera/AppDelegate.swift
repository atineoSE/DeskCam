//
//  AppDelegate.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 9/1/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSWindow.makeWindowTopMost()
        NSWindow.setTransparency()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func didToggleView(_ sender: Any) {
        print("APP DELEGATE: toggled view")
        guard
            let cameraViewController = NSApplication.shared.mainWindow?.windowController?.contentViewController as? CameraViewController
        else {
            print("MAIN APPLICATION: ERROR - could not find camera view controller")
            return
        }
        cameraViewController.dummyFunc()
    }
}
