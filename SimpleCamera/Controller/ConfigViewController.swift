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

    @IBOutlet weak var backgroundViewTwo: NSView!
    @IBOutlet weak var positionButtonTwo: NSPopUpButton!
    @IBOutlet weak var maskButtonTwo: NSPopUpButton!
    @IBOutlet weak var sizeButtonTwo: NSPopUpButton!
    
    weak var stateController: StateController?
    private lazy var allButtons: [NSPopUpButton] = [
        positionButtonOne, maskButtonOne, sizeButtonOne,
        positionButtonTwo, maskButtonTwo, sizeButtonTwo
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundViews()
        setupPopUpButtons()
    }
    @IBAction func didChangeButton(_ sender: NSPopUpButton) {
        print("Changed \(sender.identifier) button to \(sender.selectedItem?.title) ")
    }
    
   @objc
    func positionDidChange(at button: NSPopUpButton, index: Int) {
        guard
            let positionTitle = button.selectedItem?.title,
            let newPosition = Position(rawValue: positionTitle)
        else {
            return
        }
        AppLogger.debug("CONFIG_VIEW_CONTROLLER: Position changed to \(newPosition) at index \(index)")
        stateController?.update(newPosition, at: index)
    }
    
    @objc
    func maskDidChange(at button: NSPopUpButton, index: Int) {
        guard
            let maskTitle = button.selectedItem?.title,
            let newMask = Mask(rawValue: maskTitle)
        else {
            return
        }
        AppLogger.debug("CONFIG_VIEW_CONTROLLER: Mask one changed to \(newMask) at index \(index)")
        stateController?.update(newMask, at: index)
    }
    
    @objc
    func sizeOneDidChange(at button: NSPopUpButton, index: Int) {
        guard
            let sizeTitle = button.selectedItem?.title,
            let newSize = Size(rawValue: sizeTitle)
        else {
            return
        }
        AppLogger.debug("CONFIG_VIEW_CONTROLLER: Size changed to \(newSize) at index \(index)")
        stateController?.update(newSize, at: index)
    }
    
    private func setupBackgroundViews() {
        for view in [backgroundViewOne, backgroundViewTwo] {
            view?.wantsLayer = true
            view?.layer?.backgroundColor = NSColor.darkGray.cgColor
            view?.layer?.cornerRadius = 16.0
        }
    }
    
    private func setupPopUpButtons() {
        for button in allButtons {
            button.menu?.removeAllItems()
            for attribute in button.attributes {
                button.menu?.addItem(.init(title: attribute, action: nil, keyEquivalent: .init()))
            }
            //button.select(positionButtonOne.menu?.items.first(where: { $0.title == stateController?.states[0].position.rawValue}))
        }
    }
}

private extension NSPopUpButton {
    var attributes: [String] {
        guard let id = identifier?.rawValue else {
            return []
        }
        switch id {
        case "MaskOne", "MaskTwo":
            return Mask.allCases.map { $0.rawValue }
        case "PositionOne", "PositionTwo":
            return Position.allCases.map { $0.rawValue }
        case "SizeOne", "SizeTwo":
            return Size.allCases.map { $0.rawValue }
        default:
            AppLogger.error("CONFIG_VIEW_CONTROLLER: Unexpected pop up button with identifier \(id)")
            return []
        }
    }
}
