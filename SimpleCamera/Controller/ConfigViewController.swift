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

    weak var stateController: StateController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundViewOne.wantsLayer = true
        backgroundViewOne.layer?.backgroundColor = NSColor.darkGray.cgColor
        backgroundViewOne.layer?.cornerRadius = 16.0
        
        setupPopUpButtons()
    }
    
    @IBAction @objc
    func positionOneDidChange(_ sender: Any) {
        guard 
            let positionTitle = positionButtonOne.selectedItem?.title,
            let newPosition = Position(rawValue: positionTitle)
        else {
            return
        }
        AppLogger.debug("CONFIG_VIEW_CONTROLLER: Position one changed to \(newPosition)")
        stateController?.update(newPosition, isFirst: true)
    }
    
    @IBAction @objc
    func maskOneDidChange(_ sender: Any) {
        guard 
            let maskTitle = maskButtonOne.selectedItem?.title,
            let newMask = Mask(rawValue: maskTitle)
        else {
            return
        }
        AppLogger.debug("CONFIG_VIEW_CONTROLLER: Mask one changed to \(newMask)")
        stateController?.update(newMask, isFirst: true)
    }
    
    @IBAction @objc
    func sizeOneDidChange(_ sender: Any) {
        guard
            let sizeTitle = sizeButtonOne.selectedItem?.title,
            let newSize = Size(rawValue: sizeTitle)
        else {
            return
        }
        AppLogger.debug("CONFIG_VIEW_CONTROLLER: Size one changed to \(newSize)")
        stateController?.update(newSize, isFirst: true)
    }
    
    private func setupPopUpButtons() {
        positionButtonOne.menu?.removeAllItems()
        for position in Position.allCases {
            positionButtonOne.menu?.addItem(
                .init(
                    title: position.rawValue,
                    action: #selector(positionOneDidChange),
                    keyEquivalent: .init()
                )
            )
        }
        positionButtonOne.select(positionButtonOne.menu?.items.first(where: { $0.title == stateController?.states[0].position.rawValue}))

        
        maskButtonOne.menu?.removeAllItems()
        for mask in Mask.allCases {
            maskButtonOne.menu?.addItem(
                .init(
                    title: mask.rawValue,
                    action: #selector(maskOneDidChange),
                    keyEquivalent: .init()
                )
            )
        }
        maskButtonOne.select(maskButtonOne.menu?.items.first(where: { $0.title == stateController?.states[0].mask.rawValue}))
        
        sizeButtonOne.menu?.removeAllItems()
        for size in Size.allCases {
            sizeButtonOne.menu?.addItem(
                .init(
                    title: size.rawValue,
                    action: #selector(sizeOneDidChange),
                    keyEquivalent: .init()
                )
            )
        }
        sizeButtonOne.select(sizeButtonOne.menu?.items.first(where: { $0.title == stateController?.states[0].size.rawValue}))
    }
}
