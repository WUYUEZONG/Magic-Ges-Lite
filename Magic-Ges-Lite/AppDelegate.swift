//
//  AppDelegate.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/2.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @AppStorage(UserDefaults.UserKey.gestureCount.rawValue) var gestureCounting = 0

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()

    let content = ContentWindow()
    
    var toggleGestureItem = NSMenuItem()
    var countingGestureItem = NSMenuItem()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        NSApplication.shared.setActivationPolicy(.accessory)
        WZMagicMouseHandle.shared.start()
        
        if let button = statusItem.button {
            let image = NSImage(named: "logo32")
            //NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: nil)
            button.image = image

        }
        countingGestureItem.title = String(localized: "\(gestureCounting.formatted()) Gestures") //NSLocalizedString("\(gestureCounting.formatted()) Gestures", comment: "")
        menu.addItem(countingGestureItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: NSLocalizedString("Open Main Window", comment: ""), action: #selector(openStatusMenus), keyEquivalent: "o")
        menu.addItem(NSMenuItem.separator())
        toggleGestureItem.title = WZMagicMouseHandle.shared.running ? NSLocalizedString("Stop Gesture", comment: "") : NSLocalizedString("Start Gesture", comment: "")
        toggleGestureItem.action = #selector(quitGesture)
        toggleGestureItem.keyEquivalent = "E"
        menu.addItem(toggleGestureItem)
        menu.addItem(withTitle: NSLocalizedString("Exit", comment: ""), action: #selector(quitApp), keyEquivalent: "q")
        statusItem.menu = menu
        
        NSApp.activate(ignoringOtherApps: true)
        content.makeKeyAndOrderFront(self)
        if !AXIsProcessTrusted() {
            let accessibility = RequestAccessabilityView()
            let aWindow = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
            aWindow.contentView = NSHostingView(rootView: accessibility)
            aWindow.setFrame(NSRect(origin: .zero, size: aWindow.contentView?.fittingSize ?? CGSize(width: 500, height: 600)), display: true)
            aWindow.title = "RequestAccessabilityView"
            aWindow.isReleasedWhenClosed = false
            aWindow.titlebarAppearsTransparent = true
            aWindow.titleVisibility = .hidden
            aWindow.center()
            aWindow.orderFront(self)
            
        }
        
        
        
     
    }
    
    @objc func openStatusMenus() {
        NSApp.activate(ignoringOtherApps: true)
        content.makeKeyAndOrderFront(self)
    }
    
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func quitGesture() {
        let ges = WZMagicMouseHandle.shared
        if ges.running {
            ges.stop()
            toggleGestureItem.title = NSLocalizedString("Start Gesture", comment: "")
        } else {
            ges.start()
            toggleGestureItem.title = NSLocalizedString("Stop Gesture", comment: "")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

