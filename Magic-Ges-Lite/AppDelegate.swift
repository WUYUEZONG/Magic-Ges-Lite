//
//  AppDelegate.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/2.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private let accessibilityAuthorization = AccessibilityAuthorization()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
//        let _ = accessibilityAuthorization.checkAccessibility {
//
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

