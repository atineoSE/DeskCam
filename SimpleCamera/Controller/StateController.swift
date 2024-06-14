//
//  StateController.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

class StateController {
    var states: [State]
    
    init() {
        states = [
            AppSettings.getState(isFirst: true) ?? State.default,
            AppSettings.getState(isFirst: false) ?? State.default
        ]
        AppLogger.debug("STATE_CONTROLLER: initialized with states \(states)")
    }
    
    func update(_ mask: Mask, isFirst:Bool) {
        let index = isFirst ? 0 : 1
        states[index] = State(mask: mask, size: states[index].size, position: states[index].position)
    }
    
    func update(_ position: Position, isFirst: Bool) {
        let index = isFirst ? 0 : 1
        states[index] = State(mask: states[index].mask, size: states[index].size, position: position)
    }
    
    func update(_ size: Size, isFirst: Bool) {
        let index = isFirst ? 0 : 1
        states[index] = State(mask: states[index].mask, size: size, position: states[index].position)
    }
}
