//
//  AppSettings.swift
//  SimpleCamera
//
//  Created by Adrian Tineo Cabello on 13/6/24.
//

import Foundation

class AppSettings {
    enum Key: String, CaseIterable {
        case stateOne
        case stateTwo
        case currentIndex
    }
    
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    
    private class func getKey(at index: Int) -> String {
        index == 0 ? Key.stateOne.rawValue : Key.stateTwo.rawValue
    }
    
    class func save(_ state: State, at index: Int) {
        guard let encodedState = try? encoder.encode(state) else {
            AppLogger.debug("APP_SETTINGS: could not encode state \(state)")
            return
        }
        UserDefaults.standard.set(encodedState, forKey: getKey(at: index))
        UserDefaults.standard.synchronize()
    }
    
    class func state(at index: Int) -> State? {
        guard let data = UserDefaults.standard.data(forKey: getKey(at: index)) else {
            return nil
        }
        return try? decoder.decode(State.self, from: data)
    }
    
    static var currentIndex: Int {
        UserDefaults.standard.integer(forKey: Key.currentIndex.rawValue)
    }
    
    class func setCurrentState(at index: Int) {
        UserDefaults.standard.setValue(index, forKey: Key.currentIndex.rawValue)
    }
    
    class func removeAllStates() {
        for key in Key.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
}

