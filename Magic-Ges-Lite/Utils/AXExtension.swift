//
//  AXExtension.swift
//  Rectangle
//
//  Copyright © 2022 Ryan Hanson. All rights reserved.
//

import Foundation
import AppKit.NSAccessibility
import SwiftUI

//var a = _AXUIElementGetWindow(AXUIElementRef element, uint32_t *identifier);



extension NSAccessibility.Attribute {
    static let enhancedUserInterface = NSAccessibility.Attribute(rawValue: "AXEnhancedUserInterface")
    static let windowIds = NSAccessibility.Attribute(rawValue: "AXWindowsIDs")
}

extension AXValue {
    func toValue<T>() -> T? {
        let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
        let success = AXValueGetValue(self, AXValueGetType(self), pointer)
        let value = pointer.pointee
        pointer.deallocate()
        return success ? value : nil
    }
    
    static func from<T>(value: T, type: AXValueType) -> AXValue? {
        var value = value
        return AXValueCreate(type, &value)
    }
}

extension AXUIElement {
    static let systemWide = AXUIElementCreateSystemWide()
    
    func isValueSettable(_ attribute: NSAccessibility.Attribute) -> Bool? {
        var isSettable = DarwinBoolean(false)
        let result = AXUIElementIsAttributeSettable(self, attribute.rawValue as CFString, &isSettable)
        guard result == .success else { return nil }
        return isSettable.boolValue
    }
    
    /// AXUIElementCopyAttributeValue
    func getValue(_ attribute: NSAccessibility.Attribute) -> AnyObject? {
        var value: AnyObject?
        let result = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
        guard result == .success else { return nil }
        return value
    }
    
    func getWrappedValue<T>(_ attribute: NSAccessibility.Attribute) -> T? {
        guard let value = getValue(attribute), CFGetTypeID(value) == AXValueGetTypeID() else { return nil }
        return (value as! AXValue).toValue()
    }
    
    @discardableResult
    func setValue(_ attribute: NSAccessibility.Attribute, _ value: AnyObject) -> Bool {
        let error = AXUIElementSetAttributeValue(self, attribute.rawValue as CFString, value)
        if error != .success {
            debugPrint("setValue: ", error.rawValue)
            return false
        }
        
        return true
    }
    
    func setValue(_ attribute: NSAccessibility.Attribute, _ value: Bool) {
        setValue(attribute, value as CFBoolean)
    }
    
    private func setWrappedValue<T>(_ attribute: NSAccessibility.Attribute, _ value: T, _ type: AXValueType) {
        guard let value = AXValue.from(value: value, type: type) else { return }
        setValue(attribute, value)
    }
    
    func setValue(_ attribute: NSAccessibility.Attribute, _ value: CGPoint) {
        setWrappedValue(attribute, value, .cgPoint)
    }
    
    func setValue(_ attribute: NSAccessibility.Attribute, _ value: CGSize) {
        setWrappedValue(attribute, value, .cgSize)
    }
    
    func getElementAtPosition(_ position: CGPoint) -> AXUIElement? {
        var element: AXUIElement?
        let result = AXUIElementCopyElementAtPosition(self, Float(position.x), Float(position.y), &element)
        guard result == .success else { return nil }
        return element
    }
    
    func getPid() -> pid_t? {
        var pid = pid_t(0)
        let result = AXUIElementGetPid(self, &pid)
        guard result == .success else { return nil }
        return pid
    }

    
    func attributeNames() -> [String]? {
        let arrs = UnsafeMutablePointer<CFArray?>.allocate(capacity: 1)
        let namesError = AXUIElementCopyAttributeNames(self, arrs)
        guard namesError == .success else {
            debugPrint("ele error \(namesError.rawValue)")
            return nil
        }
        if let p = arrs.pointee {
//            debugPrint(p)
            return p as? [String]
        }
        return nil
    }
    
    func actions() -> [NSAccessibility.Action]? {
        var actions: CFArray?
        if AXUIElementCopyActionNames(self, &actions) == .success {
            return actions as? [NSAccessibility.Action]
        }
        return nil
        
    }
    
    func role() -> NSAccessibility.Role? {
        guard let role = getValue(.role) else { return nil }
        return role as? NSAccessibility.Role
    }
    
    var isApplicaation: Bool {
        role() == .application
    }
    
    var isWindow: Bool {
        role() == .window
    }
    
    var isFullScreen: Bool {
        if let fullScreen = getValue(.fullScreen) {
            return fullScreen as! Bool
        }
        return false
    }
    
}

extension NSAccessibility.Attribute {
    static let fullScreen = NSAccessibility.Attribute(rawValue: "AXFullScreen")
    static let frame = NSAccessibility.Attribute(rawValue: "AXFrame")
}
