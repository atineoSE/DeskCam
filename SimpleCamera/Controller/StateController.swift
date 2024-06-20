//
//  StateController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

class StateController {
    private(set) var states: [State]
    private(set) var currentIndex: Int
    private weak var delegate: StateControllerDelegate?
    private(set) var shouldAnimateTransition: Bool
    
    var currentState: State {
        states[currentIndex]
    }
    
    init(delegate: StateControllerDelegate) {
        self.delegate = delegate
        currentIndex = AppSettings.currentIndex
        states = [
            AppSettings.state(at: 0) ?? State.default,
            AppSettings.state(at: 1) ?? State.default
        ]
        shouldAnimateTransition = AppSettings.getShouldAnimateTransition()
        AppLogger.debug("STATE_CONTROLLER: initialized with states \(states)")
        AppLogger.debug("STATE_CONTROLLER: current state is \(currentState) (index \(currentIndex))")
    }
    
    func update(_ mask: Mask, at index: Int) {
        states[index].mask = mask
        didUpdate(at: index)
    }
    
    func update(_ position: Position, at index: Int) {
        states[index].position = position
        didUpdate(at: index)
    }
    
    func update(_ size: Size, at index: Int) {
        states[index].size = size
        didUpdate(at: index)
    }
    
    func update(_ segmentation: Segmentation, at index: Int) {
        states[index].segmentation = segmentation
        didUpdate(at: index)
    }
    
    func update(_ shouldAnimateTransition: Bool) {
        self.shouldAnimateTransition = shouldAnimateTransition
        AppSettings.set(shouldAnimateTransition: shouldAnimateTransition)
    }
    
    func toggleState() {
        currentIndex = (currentIndex + 1) % states.count
        AppLogger.debug("STATE_CONTROLLER: updated state to \(currentState)")
        AppSettings.setCurrentState(at: currentIndex)
        delegate?.updateState()
    }
    
    private func didUpdate(at index: Int) {
        save()
        if index == currentIndex {
            delegate?.updateState()
        }
        AppLogger.debug("STATE_CONTROLLER: updated state at \(index) to \(states[index])")
    }
    
    private func save() {
        for (index, _) in states.enumerated() {
            AppSettings.save(states[index], at: index)
        }
    }
}
