//
//  WindowUtil.swift
//  Rectangle
//
//  Copyright © 2022 Ryan Hanson. All rights reserved.
//

import Cocoa

class WindowUtil {
    private static var windowListCache = TimeoutCache<[CGWindowID]?, Set<WindowInfo>>(timeout: 100)
    
    static func getWindowList(_ ids: [CGWindowID]? = nil) -> Set<WindowInfo> {
        if let infos = windowListCache[ids] { return infos }
        var infos: Set<WindowInfo> = []
        var array: CFArray?
        if let ids = ids {
            let ptr = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: ids.count)
            for i in 0..<ids.count {
                ptr[i] = UnsafeRawPointer(bitPattern: UInt(ids[i]))
            }
            let ids = CFArrayCreate(kCFAllocatorDefault, ptr, ids.count, nil)
            array = CGWindowListCreateDescriptionFromArray(ids)
        } else {
            array = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
        }
        if let array = array {
            let count = array.getCount()
            for i in 0..<count {
                let dictionary = array.getValue(i) as CFDictionary
                let id = dictionary.getValue(kCGWindowNumber) as CFNumber
                let frame = (dictionary.getValue(kCGWindowBounds) as CFDictionary).toRect()
                let pid = dictionary.getValue(kCGWindowOwnerPID) as CFNumber
                if let frame = frame {
                    let info = WindowInfo(id: id as! CGWindowID, frame: frame, pid: pid as! pid_t)
                    infos.insert(info)
                }
            }
        }
        windowListCache[ids] = infos
        return infos
    }
    
    static func getOnScreenWindows(_ wid: CGWindowID? = nil) -> [Int: WindowInfo] {
        let windows: CGWindowListOption = wid == nil ? [ .excludeDesktopElements, .optionOnScreenOnly] : [ .excludeDesktopElements, .optionIncludingWindow]
        let wid: CGWindowID = wid ?? kCGNullWindowID
        var infos: [Int: WindowInfo] = [:]
//            .optionOnScreenOnly,
        let array: CFArray? = CGWindowListCopyWindowInfo(windows, wid)
        
        if let array = array {
            let count = array.getCount()
            for i in 0..<count {
                let dictionary = array.getValue(i) as CFDictionary
                let id = dictionary.getValue(kCGWindowNumber) as CFNumber
                let frame = (dictionary.getValue(kCGWindowBounds) as CFDictionary).toRect()
                let pid = dictionary.getValue(kCGWindowOwnerPID) as CFNumber
                if let frame = frame {
                    let info = WindowInfo(id: id as! CGWindowID, frame: frame, pid: pid as! pid_t)
                    infos[id as! Int] = info
                }
            }
        }
        return infos
    }
}

struct WindowInfo: Hashable {
    
    var hashValue: Int {
        return Int(id)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: CGWindowID
    let frame: CGRect
    let pid: pid_t
    var bundleIdentifier: String? { NSRunningApplication(processIdentifier: pid)?.bundleIdentifier }
    
    var element: AXUIElement?
}
