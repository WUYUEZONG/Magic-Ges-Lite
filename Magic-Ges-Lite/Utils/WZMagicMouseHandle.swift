//
//  WZMagicMouseHandle.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/5.
//

import Cocoa
import CoreGraphics
import Carbon.HIToolbox
import SwiftUI

class WZMagicMouseHandle {
    
    private var state: StateWindow
    
    var running: Bool { eventMonitor != nil }
    
    
    func getCancelActionDelay() -> Double {
        becomeLongActionDelay + 1
    }
    /// 设置手势延时时间
    @AppStorage(UserDefaults.UserKey.longActionDelay.rawValue) var becomeLongActionDelay: Double = 0.4
    /// 手势灵敏度
    @AppStorage(UserDefaults.UserKey.sensitivity.rawValue) var sensitivity: Double = 0.2
    
    static let shared = WZMagicMouseHandle()
    
    private var scrollWhellEvent: NSEvent?
    
    private var gestureState: StateAction = .none
//    {
//        set {
//            objc_sync_enter(self)
//            gState = newValue
//            objc_sync_exit(self)
//        }
//        get {
//            gState
//        }
//    }
    
    private var eventMonitor: Any?
    
    private var gestureEnded = true
    
    private var eventWorkItem: DispatchWorkItem?
    
    private  var changeToHoldGestureWorkItem: DispatchWorkItem?
    private  var cancelGestureWorkItem: DispatchWorkItem?
    
    private var focusedWindow: WindowInfo?
    
//    var hud: NSWindowController?
    
    init() {
        
        
        state = StateWindow()
//
        
    }
    
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    func start() {
        
        if running { return }
        
        debugPrint("eventMonitor set")
        
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.scrollWheel]) { [self] event in
            
            
            switch event.type {
            case .scrollWheel:
//                isDirectionInvertedFromDevice
                self.doScrollWheel(event: event)
                break
            default:
                debugPrint(event.description)
                break
            }
            
            
        }
    }
    
//    @objc func performEvent() {
//        eventWorkItem?.perform()
//    }
    
    func stop() {
        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
            eventMonitor = nil
        }
    }
    
    
    
    deinit {
        stop()
    }
    
    
    
}


extension WZMagicMouseHandle {
    
    
    static var isAccessabilityEnable: Bool {
        AXIsProcessTrusted()
    }
    
    static func openAccessabilityWindow() {
        NSWorkspace.shared.open(URL(string:"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
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
}






extension WZMagicMouseHandle {
    
    
    func getScrollWheelEventUnderMouseWindow(event: NSEvent) -> WindowInfo? {
        
//        guard let main = NSScreen.main else { return nil }
        
        let mouseLocation = event.locationInWindow
//        let statusY = main.visibleFrame.maxY
//        let dockY = main.visibleFrame.minY
        
        let screenWindows = WindowUtil.getOnScreenWindows()
        let current = screenWindows[event.windowNumber]
        debugPrint(screenWindows)
        debugPrint("\(event.windowNumber)")
        guard var current = current,
              current.frame.contains(mouseLocation.toCGPoint()) else { return nil }
        
        // 38 假定的应用导航栏高度
        guard mouseLocation.toCGPoint().y - current.frame.minY < 38 else { return nil }
        
        let application = AXUIElementCreateApplication(current.pid)
        
        let element = UnsafeMutablePointer<AXUIElement?>.allocate(capacity: 1)
        let copyError = AXUIElementCopyElementAtPosition(application, Float(mouseLocation.toCGPoint().x), Float(mouseLocation.toCGPoint().y), element)
        if copyError == .success {
            
            guard let elementAtPosition = element.pointee else { return nil }
            
            if elementAtPosition.isWindow {
                current.element = elementAtPosition
                debugPrint(elementAtPosition.getValue(.frame).debugDescription)
            } else {
                guard let eleWindow = elementAtPosition.getValue(.window) else { return nil }
                let ew = eleWindow as! AXUIElement
                current.element = ew
                debugPrint(ew.getValue(.frame).debugDescription)
            }
            
            return current
        } else {
            debugPrint("AXUIElementCopyElementAtPosition", copyError.rawValue)
            return nil
        }
        
//        guard let elements = application.getValue(.windows) else { return nil }
//
//        guard let lists = elements as? [AXUIElement] else  { return nil }
//
//        let windowElement = lists.first {
//            if let names = $0.attributeNames(), names.contains(NSAccessibility.Attribute.frame.rawValue) {
//                if let value = $0.getValue(.frame) {
//                    let value = value as! AXValue
////                    kAXValueCGRectType
//
//                    if let frame: CGRect = value.toValue() {
//                        let loc = mouseLocation.toCGPoint()
//                        let inX = loc.x > frame.minX && loc.x < frame.maxX
//                        let inY = loc.y - frame.minY < 38
//                        let inFrame = inY && inX
//                        return frame.equalTo(current.frame) || inFrame
//                    }
//
//
//                }
//            }
//            return false
//        }
//
//        current.element = windowElement
//        return current
    }
    
    
    func setNewFrame(action: StateAction,  for event: NSEvent) {
        
        guard let frame = action.frame else { return }
        
        guard let focusedWindow = focusedWindow, let element = focusedWindow.element else { return }
        
        guard !focusedWindow.frame.equalTo(frame) else {
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
    
    
    
    func doScrollWheel(event: NSEvent) {
        
        doScrollWhell(event: event) { action, e in
            
            self.countGesture()
            
            switch action {
                
            case let .normal(direction):
                
                switch direction {
                case .up, .left, .right:
                    self.setNewFrame(action: action, for: e)
                case .down:
                    if let focusedWindow = self.focusedWindow, let ele = focusedWindow.element {
                        self.setAttributeFor(element: ele, attribute: .minimized, value: true as CFBoolean)
                    }
                default: break
                }
                
            case let .hold(direction):
                
                switch direction {
                case .up:
                    self.pressFullScreenButton(event: e)
                case .left, .right:
                    self.setNewFrame(action: action, for: e)
                case .down:
                    self.pressCloseButton(event: e)
                    break
                default: break
                }
                
            default: break
            }
        }
        
        
    }
    
    
    func doScrollWhell(event: NSEvent, complete: ((StateAction, NSEvent) -> Void)?) {
        
        switch event.phase {
        case .began, .mayBegin:
            
            self.gestureEnded = false
            self.changeToHoldGestureWorkItem?.cancel()
            self.cancelGestureWorkItem?.cancel()
            self.gestureState = .none
            
            focusedWindow = getScrollWheelEventUnderMouseWindow(event: event)
            if let focusedWindow = focusedWindow, focusedWindow.element != nil {
                
                self.gestureState = .normal(.none)
                
                self.changeToHoldGestureWorkItem = DispatchWorkItem(block: {
                    
                    debugPrint("执行了changeToHoldGestureWorkItem is main", Thread.isMainThread)
                    
                    if self.gestureEnded  || self.gestureState == .cancel  { return }
                    
                    if let event = self.scrollWhellEvent {
                        self.gestureState = .hold(self.calEvents(event: event).direction)
                        self.state.show(self.gestureState, needHide: false)
                    }
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.becomeLongActionDelay, execute: self.changeToHoldGestureWorkItem!)
                
                
                self.cancelGestureWorkItem = DispatchWorkItem(block: {
                    debugPrint("执行了cancelGestureWorkItem is main", Thread.isMainThread)
                    if self.gestureEnded || self.gestureState == .cancel { return }
                    
                    self.gestureState = .cancel
                    self.state.show(self.gestureState)
                    
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + self.getCancelActionDelay(), execute: self.cancelGestureWorkItem!)
                
            }

            
            scrollWhellEvent = nil
            
            break
        case .changed:
            
            
            if scrollWhellEvent == nil {
                scrollWhellEvent = event
            }
            
            if event.deltaX != 0 || event.deltaY != 0 {
                scrollWhellEvent = event
            }
            
            
            if gestureState == .cancel {
                self.state.hide()
            } else {
                
                switch self.gestureState {
                case .normal:
                    self.gestureState = .normal(self.calEvents(event: scrollWhellEvent!).direction)
                    self.state.show(self.gestureState, needHide: false)
                    
                    break
                case .hold:
                    self.gestureState = .hold(self.calEvents(event: scrollWhellEvent!).direction)
                    self.state.show(self.gestureState, needHide: false)
                    break
                default: break
                }
                
            }
            
            
            
            break
        case .ended:
            
            self.gestureEnded = true
            self.changeToHoldGestureWorkItem?.cancel()
            self.cancelGestureWorkItem?.cancel()
            
            guard let focusedWindow = focusedWindow, focusedWindow.element != nil else { return }
            
            guard let scrollWhellEvent = scrollWhellEvent else { return }
            
            let shouldPreformGesture = abs(scrollWhellEvent.deltaX) > sensitivity || abs(scrollWhellEvent.deltaY) > sensitivity
            
            let result = self.calEvents(event: scrollWhellEvent)
            switch self.gestureState {
            case .normal:
                
                if shouldPreformGesture {
                    self.gestureState = .normal(result.direction)
                    self.state.show(self.gestureState)
                    complete?(self.gestureState, result.event)
                } else {
                    self.state.show(.cancel)
                }
                
                
                break
            case .hold:
                
                if shouldPreformGesture {
                    self.gestureState = .hold(result.direction)
                    self.state.show(self.gestureState)
                    complete?(self.gestureState, result.event)
                } else {
                    self.state.show(.cancel)
                }
                
                break
            default:
                self.state.hide()
                break
            }
            
            if !shouldPreformGesture {
                
                debugPrint("不符合要求的手势")
            }
            
            
            self.scrollWhellEvent = nil
            
            
        default: break
        }
        
    }
    
    func countGesture() {
        if let delegate = NSApplication.shared.delegate as? AppDelegate {
            delegate.gestureCounting += 1
            delegate.countingGestureItem.title = .gestureCounting(delegate.gestureCounting)
        }
    }
    
    func calEvents(event: NSEvent) -> (direction: StateAction.Direction, event: NSEvent) {
        if abs(event.deltaX) > abs(event.deltaY) {
            // 水平操作
            
            if event.deltaX < 0 {
                
                return (.left, event)
                
            } else {
                
                return (.right, event)
                
                
            }
            
        } else {
            if event.deltaY < 0 {
                
                if event.isDirectionInvertedFromDevice {
                    return (.up, event)
                } else {
                    return (.down, event)
                }
                
                
            } else {
                
                if event.isDirectionInvertedFromDevice {
                    return (.down, event)
                } else {
                    return (.up, event)
                }
            }
        }
    }
    
    
}


extension WZMagicMouseHandle {
    
    func setAttributeFor(element: AXUIElement, attribute: NSAccessibility.Attribute, value: AnyObject) {
  
        guard let names = element.attributeNames() else {
            return
        }
        
        if names.contains(attribute.rawValue) {
            element.setValue(attribute, value)
        }
        
    }
    
    func pressButton(event: NSEvent, button: NSAccessibility.Attribute, disable:((_ window: AXUIElement, _ button: AXUIElement) -> Void)?) {
        
        if let focusedWindow = focusedWindow, let element = focusedWindow.element {
            
            
            //                AXFocused,
            //                AXFullScreen,
            //                AXTitle,
            //                AXChildrenInNavigationOrder,
            //                AXFrame,
            //                AXPosition,
            //                AXGrowArea,
            //                AXMinimizeButton,
            //                AXDocument,
            //                AXSections,
            //                AXCloseButton,
            //                AXMain,
            //                AXActivationPoint,
            //                AXFullScreenButton,
            //                AXProxy,
            //                AXDefaultButton,
            //                AXMinimized,
            //                AXChildren,
            //                AXRole,
            //                AXParent,
            //                AXTitleUIElement,
            //                AXCancelButton,
            //                AXModal,
            //                AXSubrole,
            //                AXZoomButton,
            //                AXRoleDescription,
            //                AXSize,
            //                AXToolbarButton,
            //                AXIdentifier
            
            if let btn = element.getValue(button) {
                
                let btn = btn as! AXUIElement
                if let enable = btn.getValue(.enabled) as? Bool, enable {
                    AXUIElementPerformAction(btn, NSAccessibility.Action.press as CFString)
                } else {
                    disable?(element, btn)
                }
            }
        }

    }
    
    func pressFullScreenButton(event: NSEvent) {
        pressButton(event: event, button: .fullScreenButton) { w, e in
            if let attributes = w.attributeNames(), attributes.contains(NSAccessibility.Attribute.fullScreen.rawValue) {
                w.setValue(.fullScreen, false)
            }
        }
    }
    
    func pressCloseButton(event: NSEvent) {
        pressButton(event: event, button: .closeButton) { _, _ in
            
        }
    }
    
    
}
