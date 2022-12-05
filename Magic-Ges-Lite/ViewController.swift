//
//  ViewController.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/2.
//

import Cocoa
import CoreGraphics
import Carbon.HIToolbox

extension NSPoint {
    func toCGPoint() -> NSPoint {
        if let main = NSScreen.main {
            return NSPoint(x: x, y: main.frame.height - y)
        }
        return NSPoint(x: self.x, y: 1080 - self.y)
    }
}

extension Notification.Name {
    static let getWindowInfo = Notification.Name("com.wyz.ges.lite.getWindowInfo")
}

class ViewController: NSViewController {
    
    @IBOutlet weak var actionLabel: NSTextField!
    
    
    var menuBarScrollWhellEventX: NSEvent?
    
    var menuBarScrollWhellEventY: NSEvent?
    
//    var windows: Set<WindowInfo>!
    
    var currenWindow: WindowInfo?
    
    var currentWindowNumber = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        windows = WindowUtil.getWindowList()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {

            if AXIsProcessTrusted() {
                
                NSApp.setActivationPolicy(.accessory)

                debugPrint("已经拥有权限")
                self.actionLabel.stringValue = "已经拥有权限"
            } else {
                self.actionLabel.stringValue = "没有拥有权限"
            }
        }
        
        WZMagicMouseHandle.shared.start()
        
    }
    
    @objc
    func handleInfo(noti: Notification) {
        
        if let c = currenWindow {
            let element = AXUIElementCreateApplication(c.pid)
            let arrs = UnsafeMutablePointer<CFArray?>.allocate(capacity: 1)
            AXUIElementCopyAttributeNames(element, arrs)
            debugPrint(arrs.pointee ?? "nothing")
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func doMouseExited(event: NSEvent) {
        debugPrint("doMouseExited \(event.windowNumber)")
    }
    
    
    func getScrollWheelEventUnderMouseElement(event: NSEvent, onMenuBar:(()->Void)?, onAppNavgationBar:((AXUIElement?, CGRect?)->Void)?) {
        let etmloc = NSEvent.mouseLocation
        
        let smain = NSScreen.main!
        let statusY = smain.visibleFrame.maxY
        let dockY = smain.visibleFrame.minY
        
        var element: AXUIElement?
        var current: WindowInfo?
        
        if etmloc.y >= statusY {
            onMenuBar?()
        } else if  etmloc.y <= dockY {
            
            // dock actions
            return
            
        } else {
            
            current = WindowUtil.getWindowList().first { a in
                debugPrint("current evet \(event.windowNumber)")
                return event.windowNumber == a.id && a.frame.contains(etmloc.toCGPoint())
            }
            
            // 38 假定的应用导航栏高度
            if let current = current, etmloc.toCGPoint().y - current.frame.minY < 38 {
                element = AXUIElementCreateApplication(current.pid)
            }
            
            if let element = element {
                onAppNavgationBar?(element, current?.frame)
            }
            
        }
    }
    
    @objc
    func resetCursor() {
        NSCursor.arrow.set()
    }
    
    func maxFrame() -> CGRect {
        let main = NSScreen.main!
        return CGRect(x: 0, y: main.frame.height - main.visibleFrame.maxY, width: main.frame.width, height: main.visibleFrame.height - 1)
    }
    
    func leftHalfFrame() -> CGRect {
        let main = NSScreen.main!
        let hw = main.frame.width / 2
        return CGRect(x: 0, y: main.frame.height - main.visibleFrame.maxY, width: hw, height: main.visibleFrame.height - 1)
    }
    
    func rightHalfFrame() -> CGRect {
        let main = NSScreen.main!
        let hw = main.frame.width / 2
        return CGRect(x: hw, y: main.frame.height - main.visibleFrame.maxY, width: hw, height: main.visibleFrame.height - 1)
    }
    
    func setNewFrame(frame: CGRect, for event: NSEvent) {
        
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
            
            self.setNewFrame(frame: self.leftHalfFrame(), for: e)
            
        } up: { e in
            
            self.setNewFrame(frame: self.maxFrame(), for: e)
            
        } right: { e in
            
            self.setNewFrame(frame: self.rightHalfFrame(), for: e)
            
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
            menuBarScrollWhellEventX = nil
            menuBarScrollWhellEventY = nil
            break
        case .changed:
            if let x = menuBarScrollWhellEventX {
                let oldX = abs(x.deltaX)
                let newX = abs(event.deltaX)
                if newX > oldX {
                    menuBarScrollWhellEventX = event
                }
            } else {
                menuBarScrollWhellEventX = event
            }
            
            if let y = menuBarScrollWhellEventY {
                let oldY = abs(y.deltaY)
                let newY = abs(event.deltaY)
                if newY > oldY {
                    menuBarScrollWhellEventY = event
                }
            } else {
                menuBarScrollWhellEventY = event
            }
            
            
            break
        case .ended:
            
            guard let xEvent = menuBarScrollWhellEventX, let yEvent = menuBarScrollWhellEventY else { return }
            
            if abs(xEvent.deltaX) > abs(yEvent.deltaY) {
                // 水平操作
                
                if xEvent.deltaX < 0 {
                    debugPrint("向左⬅️划动了")
                    if let left = left {
                        left(xEvent)
                    }
//
//                            clickKeyboard(flags: .maskControl, virtualKey: kVK_LeftArrow)
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
                    
                    
//                            clickKeyboard(flagKey: kVK_Command, virtualKey: kVK_ANSI_M)
                    
                }
            }
            
            menuBarScrollWhellEventX = nil
            menuBarScrollWhellEventY = nil
            
        default: break
        }
        
    }
    
    

    
    @IBAction func resizeWindow(_ sender: Any) {
//        setOwnerOfMenuBarMinimized()
    }
    
    
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
            self.actionLabel.stringValue = "\(frontMostError.rawValue)"
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


func clickKeyboard(flags: CGEventFlags? = nil, virtualKey: Int) {
    
    let downAction = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(virtualKey), keyDown: true)
    if let down = downAction {
        
        if let f = flags {
            down.flags = f
        }
        down.post(tap: .cghidEventTap)
//        down.post(tap: .cghidEventTap)
        let upAction = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(virtualKey), keyDown: false)
        if let up = upAction {
            if let f = flags {
                up.flags = f
            }
            up.post(tap: .cghidEventTap)
        }
    }
}

func clickKeyboard(flagKey: Int, virtualKey: Int) {
    
    let flagKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(flagKey), keyDown: true)
    flagKeyDown?.post(tap: .cghidEventTap)
    
    let virtualKeyDown = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(virtualKey), keyDown: true)
    virtualKeyDown?.post(tap: .cghidEventTap)
    
    
    let virtualKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(virtualKey), keyDown: false)
    virtualKeyUp?.post(tap: .cghidEventTap)
    
    let flagKeyUp = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(flagKey), keyDown: false)
    flagKeyUp?.post(tap: .cghidEventTap)
}

