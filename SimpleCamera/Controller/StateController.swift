//
//  StateController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

class StateController {
    private(set) var states: [State]
    private var currentIndex: Int
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
    
    func update(_ mask: Mask, isFirst:Bool) {
        states[currentIndex] = State(mask: mask, size: currentState.size, position: currentState.position)
        save()
        delegate?.updateStateIfNeeded()
    }
    
    func update(_ position: Position, isFirst: Bool) {
        states[currentIndex] = State(mask: currentState.mask, size: currentState.size, position: position)
        save()
        delegate?.updateStateIfNeeded()
    }
    
    func update(_ size: Size, isFirst: Bool) {
        states[currentIndex] = State(mask: currentState.mask, size: size, position: currentState.position)
        save()
        delegate?.updateStateIfNeeded()
    }
    
    func toggleState() {
        currentIndex = (currentIndex + 1) % states.count
        AppSettings.setCurrentState(at: currentIndex)
        delegate?.updateStateIfNeeded()
    }
    
    private func save() {
        for (index, _) in states.enumerated() {
            AppSettings.save(states[index], at: index)
        }
    }
}
