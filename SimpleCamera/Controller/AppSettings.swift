//
//  AppSettings.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

class AppSettings {
    enum Key: String {
        case stateOne
        case stateTwo
    }
    
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    
    private class func getKey(isFirst: Bool) -> String {
        isFirst ? Key.stateOne.rawValue : Key.stateTwo.rawValue
    }
    
    class func saveState(_ state: State, isFirst: Bool) {
        guard let encodedState = try? encoder.encode(state) else {
            AppLogger.debug("APP_SETTINGS: could not encode state \(state)")
            return
        }
        UserDefaults.standard.set(encodedState, forKey: getKey(isFirst: isFirst))
        UserDefaults.standard.synchronize()
    }
    
    class func getState(isFirst: Bool) -> State? {
        guard let data = UserDefaults.standard.data(forKey: getKey(isFirst: isFirst)) else {
            return nil
        }
        return try? decoder.decode(State.self, from: data)
    }
    
    class func removeAllStates() {
        UserDefaults.standard.removeObject(forKey: Key.stateOne.rawValue)
        UserDefaults.standard.removeObject(forKey: Key.stateTwo.rawValue)
        UserDefaults.standard.synchronize()
    }
}

