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

    private let accessibilityAuthorization = AccessibilityAuthorization()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        NSApplication.shared.setActivationPolicy(.accessory)
        
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.isVisible = true
        let image = NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: nil)
        
        statusItem.button?.image = image
        statusItem.button?.action = #selector(openStatusMenus)
        
        
        
        let content = ContentWindow()
        let vc = NSWindowController(window: content)
        NSApp.activate(ignoringOtherApps: true)
        vc.showWindow(self)
        if !AXIsProcessTrusted() {
            let accessibility = RequestAccessabilityView()
            let aWindow = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
            aWindow.contentView = NSHostingView(rootView: accessibility)
            aWindow.setFrame(NSRect(origin: .zero, size: aWindow.contentView?.fittingSize ?? CGSize(width: 500, height: 600)), display: true)
            aWindow.title = "RequestAccessabilityView"
            aWindow.isReleasedWhenClosed = false
            aWindow.titlebarAppearsTransparent = true
            aWindow.titleVisibility = .hidden
//            aWindow.
            aWindow.center()
            aWindow.orderFront(self)
            
        }
        
     
    }
    
    @objc func openStatusMenus() {
        
    }
    
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

