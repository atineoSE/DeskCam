//
//  ConfigViewController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Cocoa

class ConfigViewController: NSViewController {

    @IBOutlet weak var backgroundViewOne: NSView!
    @IBOutlet weak var positionButtonOne: NSPopUpButton!
    @IBOutlet weak var maskButtonOne: NSPopUpButton!
    @IBOutlet weak var sizeButtonOne: NSPopUpButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundViewOne.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
    @IBAction func positionOneDidChange(_ sender: Any) {
        print("Position one changed to \(String(describing: positionButtonOne.selectedItem?.title))")
    }
    
    @IBAction func maskOneDidChange(_ sender: Any) {
        print("Mask one changed to \(String(describing: maskButtonOne.selectedItem?.title))")
    }
    
    @IBAction func sizeOneDidChange(_ sender: Any) {
        print("Size one changed to \(String(describing: sizeButtonOne.selectedItem?.title))")
    }
}
