//
//  ContentWindow.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/10.
//

import AppKit
import SwiftUI

class ContentWindow: NSPanel {
    
    
    
    init() {
        
        
        super.init(contentRect: CGRect(x: 0, y: 0, width: 700, height: 450), styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        
        
//        title = "MG"
//        titlebarAppearsTransparent = true
        
        isReleasedWhenClosed = false

        collectionBehavior.insert(.transient)
        
        contentView = NSHostingView(rootView: ContentView())
        center()

    }
    
    
}
