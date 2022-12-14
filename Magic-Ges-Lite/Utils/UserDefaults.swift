//
//  UserDefaults.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/7.
//

import Foundation


extension UserDefaults {
    enum UserKey: String {
        case longActionDelay = "WZMagicMouseHandle.UserKeys.longActionDelay"
        case sensitivity = "WZMagicMouseHandle.UserKeys.sensitivity"
        case gestureCount = "WZMagicMouseHandle.UserKeys.gestureCount"
        case stateHudByMouse = "WZMagicMouseHandle.UserKeys.stateHudByMouse"
    }
    
    func object(for key: UserKey) -> Double? {
        objectWrapper(for: key)
    }
    
    func object(for key: UserKey) -> Bool? {
        objectWrapper(for: key)
    }
    
    private func objectWrapper<T>(for key: UserKey) -> T? {
        guard let object = object(forKey: key.rawValue) else { return nil }
        return object as? T
    }
    
    func set(_ value: Any? , for key: UserKey) {
        guard let value = value else { return }
        setValue(value, forKey: key.rawValue)
        if synchronize() {
            debugPrint("setting success, \(key.rawValue), \(value)")
        }
    }
}
