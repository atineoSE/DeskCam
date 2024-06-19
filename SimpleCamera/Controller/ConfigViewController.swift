//
//  ConfigViewController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Cocoa

class ConfigViewController: NSViewController {
    
    @IBOutlet weak var labelViewOne: NSTextField!
    @IBOutlet weak var backgroundViewOne: NSView!
    @IBOutlet weak var positionButtonOne: NSPopUpButton!
    @IBOutlet weak var maskButtonOne: NSPopUpButton!
    @IBOutlet weak var sizeButtonOne: NSPopUpButton!
    @IBOutlet weak var segmentationButtonOne: NSPopUpButton!
    
    @IBOutlet weak var labelViewTwo: NSTextField!
    @IBOutlet weak var backgroundViewTwo: NSView!
    @IBOutlet weak var positionButtonTwo: NSPopUpButton!
    @IBOutlet weak var maskButtonTwo: NSPopUpButton!
    @IBOutlet weak var sizeButtonTwo: NSPopUpButton!
    @IBOutlet weak var segmentationButtonTwo: NSPopUpButton!
    
    weak var stateController: StateController?
    private lazy var viewOneButtons: [NSPopUpButton] = [positionButtonOne, maskButtonOne, sizeButtonOne, segmentationButtonOne]
    private lazy var viewTwoButtons: [NSPopUpButton] = [positionButtonTwo, maskButtonTwo, sizeButtonTwo, segmentationButtonTwo]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabels()
        setupBackgroundViews()
        setupPopUpButtons()
    }
    
    @IBAction func didChangeButton(_ sender: NSPopUpButton) {
        guard 
            let id = sender.identifier?.rawValue,
            let title = sender.selectedItem?.title
        else {
            return
        }
        print("Change \(id) button to \(title)")
        switch id {
        case "MaskOne":
            if let mask = Mask(rawValue: title) {
                stateController?.update(mask, at: 0)
            }
        case "MaskTwo":
            if let mask = Mask(rawValue: title) {
                stateController?.update(mask, at: 1)
            }
        case "PositionOne":
            if let position = Position(rawValue: title) {
                stateController?.update(position, at: 0)
            }
        case "SegmentationOne":
            if let segmentation = Segmentation(rawValue: title) {
                stateController?.update(segmentation, at: 0)
            }
        case "PositionTwo":
            if let position = Position(rawValue: title) {
                stateController?.update(position, at: 1)
            }
        case "SizeOne":
            if let size = Size(rawValue: title) {
                stateController?.update(size, at: 0)
            }
        case "SizeTwo":
            if let size = Size(rawValue: title) {
                stateController?.update(size, at: 1)
            }
        case "SegmentationTwo":
            if let segmentation = Segmentation(rawValue: title) {
                stateController?.update(segmentation, at: 1)
            }
        default:
            AppLogger.error("CONFIG_VIEW_CONTROLLER: Unexpected pop up button with identifier \(id)")
            return
        }
    }
    
    @IBAction func didToggleView(_ sender: Any) {
        stateController?.toggleState()
        setupLabels()
    }
    
    private func setupLabels() {
        guard let currentIndex = stateController?.currentIndex else {
            return
        }
        labelViewOne.stringValue = "View 1" + (currentIndex == 0 ? " (active)" : "")
        labelViewTwo.stringValue = "View 2" + (currentIndex == 1 ? " (active)" : "")
    }
    
    private func setupBackgroundViews() {
        for view in [backgroundViewOne, backgroundViewTwo] {
            view?.wantsLayer = true
            view?.layer?.backgroundColor = NSColor.darkGray.cgColor
            view?.layer?.cornerRadius = 16.0
        }
    }
    
    private func setupPopUpButtons() {
        for (index, buttons) in [viewOneButtons, viewTwoButtons].enumerated() {
            for button in buttons {
                button.menu?.removeAllItems()
                for attribute in button.attributes {
                    button.menu?.addItem(.init(title: attribute, action: nil, keyEquivalent: .init()))
                }
                if let state = stateController?.states[index] {
                    button.select(button.menu?.items.first(where: { $0.title == button.title(from: state) } ))
                }
            }
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
        case "SegmentationOne", "SegmentationTwo":
            return Segmentation.allCases.map { $0.rawValue }
        default:
            AppLogger.error("CONFIG_VIEW_CONTROLLER: Unexpected pop up button with identifier \(id)")
            return []
        }
    }
    
    func title(from state: State) -> String? {
        guard let id = identifier?.rawValue else {
            return nil
        }
        switch id {
        case "MaskOne", "MaskTwo":
            return state.mask.rawValue
        case "PositionOne", "PositionTwo":
            return state.position.rawValue
        case "SizeOne", "SizeTwo":
            return state.size.rawValue
        case "SegmentationOne", "SegmentationTwo":
            return state.segmentation.rawValue
        default:
            AppLogger.error("CONFIG_VIEW_CONTROLLER: Unexpected pop up button with identifier \(id)")
            return nil
        }
    }
}
