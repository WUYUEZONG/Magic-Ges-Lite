//
//  CGRectExtension.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/5.
//

import Foundation
import AppKit


extension CGRect {
    
    static var visiableMax: CGRect? {
        if let main = NSScreen.main {
            return CGRect(x: 0, y: main.frame.height - main.visibleFrame.maxY, width: main.frame.width, height: main.visibleFrame.height - 1)
        }
        return nil
    }
    
    static var leftHalf: CGRect? {
        if let main = NSScreen.main {
            let hw = main.frame.width / 2
            return CGRect(x: 0, y: main.frame.height - main.visibleFrame.maxY, width: hw, height: main.visibleFrame.height - 1)
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
    
    
}
