//
//  WZMagicMouseHandle.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/5.
//

import Cocoa
import CoreGraphics
import Carbon.HIToolbox

class WZMagicMouseHandle {
    
    /// start lisening global mouse events (.scrollWheel)
    func start() { }
    
    static let shared = WZMagicMouseHandle()
    
    private var scrollWhellEventX: NSEvent?
    
    private var scrollWhellEventY: NSEvent?
    
    
    
    init() {
        NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [self] event in
            switch event.type {
            case .scrollWheel:
                doScrollWheel(event: event)
                break
            default: break
            }
        }
    }
    
    
    
}








extension WZMagicMouseHandle {
    
    
    func getScrollWheelEventUnderMouseElement(event: NSEvent, onMenuBar:(()->Void)?, onAppNavgationBar:((AXUIElement?, CGRect?)->Void)?) {
        
        guard let main = NSScreen.main else { return }
        
        let mouseLocation = NSEvent.mouseLocation
        let statusY = main.visibleFrame.maxY
        let dockY = main.visibleFrame.minY
        
        var element: AXUIElement?
        var current: WindowInfo?
        
        if mouseLocation.y >= statusY {
            onMenuBar?()
        } else if  mouseLocation.y <= dockY {
            
            // dock actions
            return
            
        } else {
            
            current = WindowUtil.getWindowList().first { a in
                debugPrint("current evet \(event.windowNumber)")
                return event.windowNumber == a.id && a.frame.contains(mouseLocation.toCGPoint())
            }
            
            // 38 假定的应用导航栏高度
            if let current = current, mouseLocation.toCGPoint().y - current.frame.minY < 38 {
                element = AXUIElementCreateApplication(current.pid)
            }
            
            if let element = element {
                onAppNavgationBar?(element, current?.frame)
            }
            
        }
    }
    
    
    func setNewFrame(frame: CGRect?, for event: NSEvent) {
        
        guard let frame = frame else { return }
        
        self.getScrollWheelEventUnderMouseElement(event: event, onMenuBar: nil) { element, eFrame in
            
            guard let element = element else { return }
            
            if let eFrame = eFrame, eFrame.equalTo(frame) {
                debugPrint("无需操作")
                return
            }
            
            var origin = frame.origin
            if let setOrigin = AXValueCreate(.cgPoint, &origin) {
                self.setAttributeFor(element: element, attribute: .position, value: setOrigin)
            }
            
            var size = frame.size
            if let setSize = AXValueCreate(.cgSize, &size) {
                self.setAttributeFor(element: element, attribute: .size, value: setSize)
            }
            
        }
        
    }
    
    
    func doScrollWheel(event: NSEvent) {
        
        doScrollWhell(event: event) { e in
            
            self.setNewFrame(frame: .leftHalf, for: e)
            
        } up: { e in
            
            self.setNewFrame(frame: .visiableMax, for: e)
            
        } right: { e in
            
            self.setNewFrame(frame: .rightHalf, for: e)
            
        } down: { e in
            
            self.getScrollWheelEventUnderMouseElement(event: e, onMenuBar: nil) { ele, _ in
                guard let ele = ele else { return }
                self.setAttributeFor(element: ele, attribute: .minimized, value: true as CFBoolean)
            }
            
            

        }
    }
    
    
    func doScrollWhell(event: NSEvent, left: ((NSEvent) -> Void)?, up: ((NSEvent) -> Void)?, right: ((NSEvent) -> Void)?, down: ((NSEvent) -> Void)?) {
        switch event.phase {
        case .began, .mayBegin:
            scrollWhellEventX = nil
            scrollWhellEventY = nil
            break
        case .changed:
            if let x = scrollWhellEventX {
                let oldX = abs(x.deltaX)
                let newX = abs(event.deltaX)
                if newX > oldX {
                    scrollWhellEventX = event
                }
            } else {
                scrollWhellEventX = event
            }
            
            if let y = scrollWhellEventY {
                let oldY = abs(y.deltaY)
                let newY = abs(event.deltaY)
                if newY > oldY {
                    scrollWhellEventY = event
                }
            } else {
                scrollWhellEventY = event
            }
            
            
            break
        case .ended:
            
            guard let xEvent = scrollWhellEventX, let yEvent = scrollWhellEventY else { return }
            
            if abs(xEvent.deltaX) > abs(yEvent.deltaY) {
                // 水平操作
                
                if xEvent.deltaX < 0 {
                    debugPrint("向左⬅️划动了")
                    if let left = left {
                        left(xEvent)
                    }
                } else {
                    debugPrint("向右➡️划动了")
                    if let right = right {
                        right(xEvent)
                    }
                    
                }
                
            } else {
                if yEvent.deltaY < 0 {
                    // 向上， 放大操作
                    debugPrint("向上⬆️划动了")
                    if let up = up {
                        up(yEvent)
                    }
                } else {
                    debugPrint("向下⬇️划动了 \(event.debugDescription)")
//                    actionLabel.stringValue = "在菜单栏向下⬇️划动了"
                    if let down = down {
                        down(yEvent)
                    }
                    
                }
            }
            
            scrollWhellEventX = nil
            scrollWhellEventY = nil
            
        default: break
        }
        
    }
    
    
}


extension WZMagicMouseHandle {
    
    func setAttributeFor(element: AXUIElement, attribute: NSAccessibility.Attribute, value: AnyObject) {
        
        guard let elements = getAttribute(.windows, element: element) else {
            return
        }
        
        guard let lists = elements as? Array<AXUIElement>, let first = lists.first else {
            return
        }
        
        guard let names = printAttributeNames(first) else {
            return
        }
        
        if names.contains(attribute.rawValue) {
            setAttribute(attribute, element: first, value: value)
            
        }
        
    }
    
    func printAttributeNames(_ ele: AXUIElement) -> [String]? {
        let arrs = UnsafeMutablePointer<CFArray?>.allocate(capacity: 1)
        let namesError = AXUIElementCopyAttributeNames(ele, arrs)
        guard namesError == .success else {
            debugPrint("ele error \(namesError.rawValue)")
//            self.actionLabel.stringValue = "ele error \(namesError.rawValue)"
            return nil
        }
        if let p = arrs.pointee {
            debugPrint(p)
            return p as? [String]
        }
        return nil
    }
    
    @discardableResult
    func getAttribute(_ attribute: NSAccessibility.Attribute, element: AXUIElement) -> AnyObject? {
        var copyedValue: AnyObject?
        let att = attribute as CFString
        let frontMostError = AXUIElementCopyAttributeValue(element, att, &copyedValue)
        if let _ = copyedValue {
            debugPrint("get attribute \(frontMostError.rawValue)")
        }
        return copyedValue
    }
    
    func setAttribute(_ attribute: NSAccessibility.Attribute, element: AXUIElement, value: AnyObject) {
//        getAttribute(attribute, element: element)
        let att = attribute as CFString
        let setError = AXUIElementSetAttributeValue(element, att, value)
        debugPrint("setAttribute----\(setError.rawValue)")
//        self.actionLabel.stringValue = "----\(setError.rawValue)"
    }
}
