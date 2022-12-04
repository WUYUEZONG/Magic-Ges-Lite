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
    func toCGPoint() -> CGPoint {
        if let main = NSScreen.main {
            return CGPointMake(self.x, main.frame.height - self.y)
        }
        return CGPointMake(self.x, 1080 - self.y)
    }
}

extension Notification.Name {
    static let getWindowInfo = Notification.Name("com.wyz.ges.lite.getWindowInfo")
}

class ViewController: NSViewController {
    
    @IBOutlet weak var actionLabel: NSTextField!
    
    
    var menuBarScrollWhellEventX: NSEvent?
    
    var menuBarScrollWhellEventY: NSEvent?
    
    var windows: Set<WindowInfo>!
    
    var currenWindow: WindowInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        windows = WindowUtil.getWindowList()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            let dic = NSDictionary(object: kCFBooleanTrue, forKey: kAXTrustedCheckOptionPrompt.takeRetainedValue()
            if AXIsProcessTrusted() {
//                self.accessibilityWindowController?.close()
//                self.accessibilityWindowController = nil
//                completion()
                debugPrint("已经拥有权限")
                self.actionLabel.stringValue = "已经拥有权限"
            } else {
                self.actionLabel.stringValue = "没有拥有权限"
            }
        }
        
//        NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [self] event in
////            doMouseMoved(event: event)
//            return NSEvent()
//        }
        
        
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .mouseEntered, .scrollWheel]) { [self] event in
//            debugPrint(event.window?.contentView.debugDescription)

            switch event.type {
            case .mouseMoved:
                doMouseMoved(event: event)
                break
            case .mouseEntered:
                doMouseEntered(event: event)
                break
            case .scrollWheel:
                doScrollWheel(event: event)
                break
            default: break
            }

        }

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInfo(noti:)), name: .getWindowInfo, object: nil)
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
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        debugPrint(event.debugDescription)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.actionLabel.stringValue = "鼠标进来了"
    }
    
    func doMouseMoved(event: NSEvent) {
        
//        for app in NSWorkspace.shared.runningApplications {
//
//        }
        currenWindow = nil
        let current = windows.first { winfo in
            return winfo.id == event.windowNumber
        }
        if let current = current {
            let localPoint = event.locationInWindow.toCGPoint()
            if current.frame.contains(localPoint) {
                if (localPoint.y - current.frame.origin.y) < 38 {
//                    debugPrint("好像在程序\(event.windowNumber)的标题栏")
                    currenWindow = current
                } else {
//                    debugPrint("程序\(event.windowNumber)的非标题栏")
                }
            } else {
//                debugPrint("不再程序\(event.windowNumber)内")
            }

        } else {
            self.actionLabel.stringValue = "没有相应的程序\(event.windowNumber)"
        }

    }
    
    func doMouseEntered(event: NSEvent) {
        debugPrint(#function, "\(event)")
//        switch event.phase {
//        case .ended:
//            debugPrint(#function, "\(event)")
//            break
//        default: break
//        }
    }
    
    func doScrollWheel(event: NSEvent) {
        
        if let _ = currenWindow {
            
            doScrollWhell(event: event) { e in
                
            } up: { e in
                
            } right: { e in
                
            } down: { e in
//                NotificationCenter.default.post(Notification(name: .getWindowInfo, object: nil))
                self.theOwnerOfMenuBar()
            }

            
            
        } else if event.locationInWindow.y > 1055 {
            
//                debugPrint(event.debugDescription)
            doScrollWhell(event: event) { e in
                clickKeyboard(flagKey: kVK_Control, virtualKey: kVK_LeftArrow)
            } up: { e in
                clickKeyboard(flagKey: kVK_Control, virtualKey: kVK_RightArrow)
            } right: { e in
                
            } down: { e in
                
                self.theOwnerOfMenuBar()
//                self.resizeWindow(Any.self)
                
//                if e.modifierFlags.contains(.control) {
//                    clickKeyboard(virtualKey: kVK_DownArrow)
//                } else {
//                    clickKeyboard(flags: .maskCommand, virtualKey: kVK_ANSI_M)
//                }
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
//                    debugPrint("new:\(newX) old:\(oldX) x changed = \(event.deltaX)")
                }
            } else {
                menuBarScrollWhellEventX = event
            }
            
            if let y = menuBarScrollWhellEventY {
                let oldY = abs(y.deltaY)
                let newY = abs(event.deltaY)
                if newY > oldY {
                    menuBarScrollWhellEventY = event
//                    debugPrint("new:\(newY) old:\(oldY) y changed = \(event.deltaY)")
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
                    debugPrint("在菜单栏向左⬅️划动了")
                    if let left = left {
                        left(xEvent)
                    }
//
//                            clickKeyboard(flags: .maskControl, virtualKey: kVK_LeftArrow)
                } else {
                    debugPrint("在菜单栏向右➡️划动了")
                    if let right = right {
                        right(xEvent)
                    }
                    
                }
                
            } else {
                if yEvent.deltaY < 0 {
                    // 向上， 放大操作
                    debugPrint("在菜单栏向上⬆️划动了")
                    if let up = up {
                        up(yEvent)
                    }
                } else {
                    debugPrint("在菜单栏向下⬇️划动了 \(event.debugDescription)")
                    actionLabel.stringValue = "在菜单栏向下⬇️划动了"
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
    
    func setFrontMostAppSize() {
        
        
        
        if let app = NSWorkspace.shared.frontmostApplication {
            let axuiElement = AXUIElementCreateApplication(app.processIdentifier)
            
//            let element = AccessibilityElement(axuiElement)
//            var newSize = CGSize(width: 1200, height: 700)
//            var newPosition = CGPoint(x: 0, y: 100)
//            element.setFrame(CGRect(origin: newPosition, size: newSize))
        
            let userInterface = NSAccessibility.Attribute(rawValue: "AXEnhancedUserInterface").rawValue as CFString
            var copyedAttribute: AnyObject?
            AXUIElementCopyAttributeValue(axuiElement, userInterface, &copyedAttribute)
            if let enable = copyedAttribute as? Bool, enable {
                AXUIElementSetAttributeValue(axuiElement, userInterface, false as CFBoolean)
            }

            var newSize = CGSize(width: 1200, height: 700)
            if let value = AXValueCreate(.cgSize, &newSize) {

                let sizeError = AXUIElementSetAttributeValue(axuiElement, NSAccessibility.Attribute.size.rawValue as CFString, value)
                debugPrint(sizeError.rawValue)
            } else {
                debugPrint("尺寸失败")
            }

            var newPosition = CGPoint(x: 0, y: 100)
            if let vp = AXValueCreate(.cgPoint, &newPosition) {
                let pError = AXUIElementSetAttributeValue(axuiElement, NSAccessibility.Attribute.position.rawValue as CFString, vp)
                debugPrint(pError.rawValue)
            }


            if let value = AXValueCreate(.cgSize, &newSize) {

                let sizeError = AXUIElementSetAttributeValue(axuiElement, NSAccessibility.Attribute.size.rawValue as CFString, value)
                debugPrint(sizeError.rawValue)
            } else {
                debugPrint("尺寸失败")
            }
//
        } else {
            debugPrint("获取激活的窗口失败")
        }
        
        
        
        
        
    }

    
    @IBAction func resizeWindow(_ sender: Any) {
        theOwnerOfMenuBar()
    }
    
    func theOwnerOfMenuBar() {
        
        guard let app = NSWorkspace.shared.menuBarOwningApplication else {
            self.actionLabel.stringValue = "menuBarOwningApplication error"
            return
        }
        
        let element = AXUIElementCreateApplication(app.processIdentifier)
        
        printAttributeNames(element)
        
        guard let elements = getAttribute(.windows, element: element) else {
            return
        }
        
        
        
        if let lists = elements as? Array<AXUIElement>, let first = lists.first {
            setAttribute(NSAccessibility.Attribute.minimized, element: first, value: true as CFBoolean)
            //                setAttribute(NSAccessibility.Attribute(rawValue: "AXFullScreen"), element: first, value: true as CFBoolean)
            //                setAttribute(NSAccessibility.Attribute(rawValue: "AXMinimized"), element: first, value: true as CFBoolean)
            printAttributeNames(first)
        }
            
        
    }
    
    func printAttributeNames(_ ele: AXUIElement) {
        let arrs = UnsafeMutablePointer<CFArray?>.allocate(capacity: 1)
        let namesError = AXUIElementCopyAttributeNames(ele, arrs)
        guard namesError == .success else {
            self.actionLabel.stringValue = "ele error \(namesError.rawValue)"
            return
        }
        if let p = arrs.pointee {
            debugPrint(p)
        }
    }
    
    @discardableResult
    func getAttribute(_ attribute: NSAccessibility.Attribute, element: AXUIElement) -> AnyObject? {
        var copyedValue: AnyObject?
        let att = attribute as CFString
        let frontMostError = AXUIElementCopyAttributeValue(element, att, &copyedValue)
        if let _ = copyedValue {
            self.actionLabel.stringValue = "\(frontMostError.rawValue)"
        }
        return copyedValue
    }
    
    func setAttribute(_ attribute: NSAccessibility.Attribute, element: AXUIElement, value: AnyObject) {
//        getAttribute(attribute, element: element)
        let att = attribute as CFString
        let setError = AXUIElementSetAttributeValue(element, att, value)
        self.actionLabel.stringValue = "----\(setError.rawValue)"
    }
    
    
    
}


func clickKeyboard(flags: CGEventFlags? = nil, virtualKey: Int) {
    
    let downAction = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(virtualKey), keyDown: true)
    if let down = downAction {
        if let f = flags {
            down.flags = f
        }
        down.post(tap: .cghidEventTap)
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

