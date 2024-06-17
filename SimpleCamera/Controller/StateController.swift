//
//  StateController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

class StateController {
    private(set) var states: [State]
    private var isFirst: Bool
    private weak var delegate: WindowDelegate?
    
    private var currentIndex: Int {
        isFirst ? 0 : 1
    }
    
    var currentState: State {
        states[currentIndex]
    }
    
    init(delegate: WindowDelegate) {
        self.delegate = delegate
        isFirst = !AppSettings.isCurrentStateSecond()
        states = [
            AppSettings.getState(isFirst: true) ?? State.default,
            AppSettings.getState(isFirst: false) ?? State.default
        ]
        AppLogger.debug("STATE_CONTROLLER: initialized with states \(states)")
    }
    
    func update(_ mask: Mask, isFirst:Bool) {
        states[currentIndex] = State(mask: mask, size: currentState.size, position: currentState.position)
        save()
        delegate?.didUpdateState()
    }
    
    func update(_ position: Position, isFirst: Bool) {
        states[currentIndex] = State(mask: currentState.mask, size: currentState.size, position: position)
        save()
        delegate?.didUpdateState()
    }
    
    func update(_ size: Size, isFirst: Bool) {
        states[currentIndex] = State(mask: currentState.mask, size: size, position: currentState.position)
        save()
        delegate?.didUpdateState()
    }
    
    func toggleState() {
        isFirst.toggle()
        AppSettings.setCurrentState(isFirst: isFirst)
        delegate?.didUpdateState()
    }
    
    private func save() {
        AppSettings.saveState(states[0], isFirst: true)
        AppSettings.saveState(states[1], isFirst: false)
    }
}
