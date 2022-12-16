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
    
    func subrole() -> NSAccessibility.Subrole? {
        guard let subrole = getValue(.subrole) else { return nil }
        return subrole as? NSAccessibility.Subrole
    }
    
    func topLevelUIElement() -> AXUIElement? {
        guard let top = getValue(.topLevelUIElement) else { return nil }
        let e = top as! AXUIElement
        return e
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
    
    
    var description: String {
        let description = getValue(.description) as? String
        return description ?? ""
    }
    
    var frame: CGRect {
        if let rect = getValue(.frame) {
            let frame: CGRect = (rect as! AXValue).toValue() ?? .zero
            return frame
        }
        return .zero
    }
    
}

extension AXUIElement {
    
    var isDockItem: Bool {
        role() == .dockItem && subrole() == .applicationDockItem
    }
    
    var isMenuBar: Bool {
        role() == .menuBar
    }
    
    var isDesktop: Bool {
        let desktopDescription = description == "桌面" || description == "Desktop"
        let frame = NSScreen.screens[0].frame.equalTo(self.frame)
        return desktopDescription && frame
        
    }
    
    func performAction(_ action: NSAccessibility.Action) {
        let actionError = AXUIElementPerformAction(self, action.rawValue as CFString)
        if actionError != .success {
            debugPrint("actionError", actionError.rawValue)
        }
    }
    
    func showExpose() {
        performAction(.showExpose)
    }
    
    func setNewFrame(action: StateAction) {
        
        guard let frame = action.frame else { return }
        
        guard !self.frame.equalTo(frame) else {
            debugPrint("无需操作")
            return
        }
        
        var origin = frame.origin
        if let setOrigin = AXValueCreate(.cgPoint, &origin) {
            setValue(.position, setOrigin)
            
        }
        
        var size = frame.size
        if let setSize = AXValueCreate(.cgSize, &size) {
            setValue(.size, setSize)
        }
    }
    
    func pressButton(_ button: NSAccessibility.Attribute, disable:((_ window: AXUIElement, _ button: AXUIElement) -> Void)?) {
        
        if let btn = getValue(button) {
            let btn = btn as! AXUIElement
            if let enable = btn.getValue(.enabled) as? Bool, enable {
                btn.performAction(.press)
            } else {
                disable?(self, btn)
            }
        }

    }
    
}

extension NSAccessibility.Attribute {
    static let fullScreen = NSAccessibility.Attribute(rawValue: "AXFullScreen")
    static let frame = NSAccessibility.Attribute(rawValue: "AXFrame")
    
}

extension NSAccessibility.Action {
    static let showExpose = NSAccessibility.Action(rawValue: "AXShowExpose")
}


extension NSAccessibility.Role {
    static let dockItem = NSAccessibility.Role(rawValue: "AXDockItem")
}

extension NSAccessibility.Subrole {
    static let applicationDockItem = NSAccessibility.Subrole(rawValue: "AXApplicationDockItem")
}
