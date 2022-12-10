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
        
        
        
        
        
        let content = ContentWindow()
        let vc = NSWindowController(window: content)
        vc.showWindow(self)
        if !AXIsProcessTrusted() {
            let accessibility = RequestAccessabilityView()
            let aWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 500), styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
            aWindow.contentView = NSHostingView(rootView: accessibility)
            aWindow.setFrame(NSRect(origin: .zero, size: aWindow.contentView?.fittingSize ?? CGSize(width: 500, height: 600)), display: true)
            aWindow.title = "RequestAccessabilityView"
            aWindow.center()
            aWindow.orderFront(self)
            
        }
        
     
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

