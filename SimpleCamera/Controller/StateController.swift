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
        AppLogger.debug("STATE_CONTROLLER: initialized with states \(states)")
        AppLogger.debug("STATE_CONTROLLER: current state is \(currentState) (index \(currentIndex))")
    }
    
    func update(_ mask: Mask, at index: Int) {
        states[index] = State(mask: mask, size: states[index].size, position: states[index].position)
        didUpdate(at: index)
    }
    
    func update(_ position: Position, at index: Int) {
        states[index] = State(mask: states[index].mask, size: states[index].size, position: position)
        didUpdate(at: index)
    }
    
    func update(_ size: Size, at index: Int) {
        states[index] = State(mask: states[index].mask, size: size, position: states[index].position)
        didUpdate(at: index)
    }
    
    func toggleState() {
        currentIndex = (currentIndex + 1) % states.count
        AppSettings.setCurrentState(at: currentIndex)
        delegate?.updateState()
    }
    
    private func didUpdate(at index: Int) {
        save()
        if index == currentIndex {
            delegate?.updateState()
        }
    }
    
    private func save() {
        for (index, _) in states.enumerated() {
            AppSettings.save(states[index], at: index)
        }
    }
}
