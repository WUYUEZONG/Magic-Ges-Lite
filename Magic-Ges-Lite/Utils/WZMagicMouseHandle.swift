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
    
//    private var state: StateWindow
    
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
    
    private var mouseOnElement: AXUIElement?
    

    
    init() {
        
        
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
    
    func getScrollWheelEventUnderMouseWindow(isOnMenuBar:(()->Void)? = nil, isDockItem:((AXUIElement)->Void)? = nil) -> AXUIElement? {
        
        let mouseLocationCGPoint = NSEvent.mouseLocation.toCGPoint()
        
        var pointElement: AXUIElement?
        
        guard AXUIElementCopyElementAtPosition(AXUIElementCreateSystemWide(), Float(mouseLocationCGPoint.x), Float(mouseLocationCGPoint.y), &pointElement) == .success else { return nil }
        
        guard let pointElement = pointElement else { return nil }
        
        if pointElement.isMenuBar {
            
//            openAppAllWindows()
            
            isOnMenuBar?()
            return nil
        }
        
        if pointElement.isDockItem {
            isDockItem?(pointElement)
            return nil
        }
        
        guard !pointElement.isDesktop else { return nil }
        
        var topLevelUIElement = pointElement.topLevelUIElement()
        if topLevelUIElement == nil {
            if pointElement.isWindow {
                topLevelUIElement = pointElement
            } else {
                return nil
            }
        }
        
        guard let topLevelUIElement = topLevelUIElement else { return nil }
        
        // 38 假定的应用导航栏高度
        guard mouseLocationCGPoint.y - topLevelUIElement.frame.minY < 38 else { return nil }
        
        return topLevelUIElement
    }
    
//    func getScrollWheelEventUnderMouseWindow(event: NSEvent) -> WindowInfo? {
//
////        guard let main = NSScreen.main else { return nil }
//
//        let mouseLocation = event.locationInWindow
////        let statusY = main.visibleFrame.maxY
////        let dockY = main.visibleFrame.minY
//
//        let screenWindows = WindowUtil.getOnScreenWindows()
//        let current = screenWindows[event.windowNumber]
//        debugPrint(screenWindows)
//        debugPrint("\(event.windowNumber)")
//        guard var current = current,
//              current.frame.contains(mouseLocation.toCGPoint()) else { return nil }
//
//        // 38 假定的应用导航栏高度
//        guard mouseLocation.toCGPoint().y - current.frame.minY < 38 else { return nil }
//
//        let application = AXUIElementCreateApplication(current.pid)
//
//        let element = UnsafeMutablePointer<AXUIElement?>.allocate(capacity: 1)
//        let copyError = AXUIElementCopyElementAtPosition(application, Float(mouseLocation.toCGPoint().x), Float(mouseLocation.toCGPoint().y), element)
//        if copyError == .success {
//
//            guard let elementAtPosition = element.pointee else { return nil }
//
//            if elementAtPosition.isWindow {
//                current.element = elementAtPosition
//                debugPrint(elementAtPosition.getValue(.frame).debugDescription)
//            } else {
//                guard let eleWindow = elementAtPosition.getValue(.window) else { return nil }
//                let ew = eleWindow as! AXUIElement
//                current.element = ew
//                debugPrint(ew.getValue(.frame).debugDescription)
//            }
//
//            return current
//        } else {
//            debugPrint("AXUIElementCopyElementAtPosition", copyError.rawValue)
////            /System/Applications/Mission Control.app
////            openMissionControlApp()
////            openAppAllWindows()
//            return nil
//        }
//
//    }
    
    
    
    
    func doScrollWheel(event: NSEvent) {
        
        switch event.phase {
        case .began, .mayBegin:
            
            self.gestureEnded = false
            self.changeToHoldGestureWorkItem?.cancel()
            self.cancelGestureWorkItem?.cancel()
            self.gestureState = .none
            
            self.mouseOnElement = getScrollWheelEventUnderMouseWindow()
            if self.mouseOnElement != nil {
                
                self.gestureState = .normal(.none)
                
                self.changeToHoldGestureWorkItem = DispatchWorkItem(block: {
                    
                    debugPrint("执行了changeToHoldGestureWorkItem is main", Thread.isMainThread)
                    
                    if self.gestureEnded  || self.gestureState == .cancel  { return }
                    
                    if let event = self.scrollWhellEvent {
                        self.gestureState = .hold(self.calEvents(event: event))
                        StateWindow.shared.show(self.gestureState, needHide: false)
                    }
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.becomeLongActionDelay, execute: self.changeToHoldGestureWorkItem!)
                
                
                self.cancelGestureWorkItem = DispatchWorkItem(block: {
                    debugPrint("执行了cancelGestureWorkItem is main", Thread.isMainThread)
                    if self.gestureEnded || self.gestureState == .cancel { return }
                    
                    self.gestureState = .cancel
                    StateWindow.shared.show(self.gestureState)
                    
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + self.getCancelActionDelay(), execute: self.cancelGestureWorkItem!)
                
            }

            
            scrollWhellEvent = nil
            
            break
        case .changed:
            
            let deltaAllowValue = sensitivity
            if abs(event.deltaX) > deltaAllowValue || abs(event.deltaY) > deltaAllowValue {
                scrollWhellEvent = event
            }
            
            
            if gestureState == .cancel {
                StateWindow.shared.hide()
            } else {
                
                if let se = scrollWhellEvent {
                    
                    switch self.gestureState {
                    case .normal:
                        StateWindow.shared.show(.normal(self.calEvents(event: se)), needHide: false)
                        
                        break
                    case .hold:
                        StateWindow.shared.show(.hold(self.calEvents(event: se)), needHide: false)
                        
                        break
                    default: break
                    }
                }
                
            }
            
            
            
            break
        case .ended:
            
            eventEnded()
            break
            
        default: break
        }
        
    }
    
    func eventEnded() {
        self.gestureEnded = true
        self.changeToHoldGestureWorkItem?.cancel()
        self.cancelGestureWorkItem?.cancel()
        
        var action: StateAction?
        
        if let scrollWhellEvent = scrollWhellEvent {
            let direction = self.calEvents(event: scrollWhellEvent)
            action = self.gestureState.reset(direction)
        }
        
        
        if let action = action, let element = getScrollWheelEventUnderMouseWindow(isOnMenuBar: {
            
            // 菜单栏的动作
            
            
        }, isDockItem: { dockItem in
            
            // dock栏的动作
            dockItem.performDockAction(action)
            
        }) {
            
            element.performAction(action)
            
        }
        
        self.scrollWhellEvent = nil
        self.mouseOnElement = nil
    }
    
    
    
    func calEvents(event: NSEvent) -> StateAction.Direction {
        if abs(event.deltaX) > abs(event.deltaY) {
            // 水平操作
            return event.deltaX < 0 ? .left : .right
            
        } else {
            
            if event.deltaY < 0 {
                
                if event.isDirectionInvertedFromDevice {
                    return .up
                } else {
                    return .down
                }
                
                
            } else {
                
                if event.isDirectionInvertedFromDevice {
                    return .down
                } else {
                    return .up
                }
            }
        }
    }
    
    
}


extension WZMagicMouseHandle {
    
    
    func openMissionControlApp() {

        if let expose = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.exposelauncher") {
//            com.apple.dt.Xcode
            NSWorkspace.shared.open(expose)
            
        }
    }
    
    
    
}
