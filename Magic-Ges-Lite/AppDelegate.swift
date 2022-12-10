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

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let menu = NSMenu()

    let content = ContentWindow()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
        NSApplication.shared.setActivationPolicy(.accessory)
        
        
        if let button = statusItem.button {
            let image = NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: nil)
            button.image = image
//            button.action = #selector(openStatusMenus)
        }
        
        menu.addItem(withTitle: "打开界面", action: #selector(openStatusMenus), keyEquivalent: "o")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "退出", action: #selector(quitApp), keyEquivalent: "q")
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
//            aWindow.
            aWindow.center()
            aWindow.orderFront(self)
            
        }
        
        WZMagicMouseHandle.shared.start()
        
     
    }
    
    @objc func openStatusMenus() {
        NSApp.activate(ignoringOtherApps: true)
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

