//
//  CGRectExtension.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/5.
//

import Foundation
import AppKit

extension NSPoint {
    func toCGPoint() -> NSPoint {
        if let main = NSScreen.main {
            return NSPoint(x: x, y: main.frame.height - y)
        }
        return NSPoint(x: self.x, y: 1080 - self.y)
    }
}

extension CGRect {
    
    
    
    static var visiableMax: CGRect? {
        if let main = NSScreen.main {
            return CGRect(x: main.visibleFrame.minX, y: main.frame.height - main.visibleFrame.maxY, width: main.visibleFrame.width, height: main.visibleFrame.height - 1)
        }
        return nil
    }
    
    static var leftHalf: CGRect? {
        if let main = NSScreen.main {
            let hw = main.frame.width / 2
            return CGRect(x: main.visibleFrame.minX, y: main.frame.height - main.visibleFrame.maxY, width: hw, height: main.visibleFrame.height - 1)
        }
        return nil
    }
    
    static var rightHalf: CGRect? {
        if let main = NSScreen.main {
            let hw = main.frame.width / 2
            return CGRect(x: hw, y: main.frame.height - main.visibleFrame.maxY, width: hw, height: main.visibleFrame.height - 1)
        }
        return nil
    }
    
    static var mostLeft: CGRect? {
        if let main = NSScreen.main {
            let hw = main.frame.width * 7 / 8
            return CGRect(x: main.visibleFrame.minX, y: main.frame.height - main.visibleFrame.maxY, width: hw, height: main.visibleFrame.height - 1)
        }
        return nil
    }
    
    static var mostRight: CGRect? {
        if let main = NSScreen.main {
            let hw = main.frame.width / 8
            return CGRect(x: hw, y: main.frame.height - main.visibleFrame.maxY, width: hw * 7, height: main.visibleFrame.height - 1)
        }
        return nil
    }
    
    
}
