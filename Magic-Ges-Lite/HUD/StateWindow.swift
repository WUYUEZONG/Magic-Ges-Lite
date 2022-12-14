//
//  StateWindow.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/8.
//

import SwiftUI



class StateWindow: NSPanel {
    
    @AppStorage(UserDefaults.UserKey.stateHudByMouse.rawValue) static var stateHudByMouse = false
    
    private let imageView = NSImageView()
    
    private let action = StateAction.none
    
    var isShowing : Bool {
        alphaValue != 0
    }
    
    func show(_ action: StateAction, needHide: Bool = true) {
        
        guard action != .none else { return }
        
        debugPrint("show", action.imageName, action, "is main", Thread.isMainThread)
        
        let image = NSImage(systemSymbolName: action.imageName, accessibilityDescription: nil)
        
        self.imageView.layer?.backgroundColor = action.style.bg.cgColor
        self.imageView.contentTintColor = action.style.tint
        self.imageView.symbolConfiguration = symbolConfiguration
        self.imageView.image = image
        if (stateHudByMouse) {
            let p = NSEvent.mouseLocation
            let o = NSPoint(x: p.x - StateWindow.contentFrame.width / 2, y: p.y -  StateWindow.contentFrame.height / 2 )
            self.setFrame(NSRect(origin: o, size: StateWindow.contentFrame.size), display: true)
        } else {
            let x = NSScreen.main!.frame.width / 2 - self.frame.width / 2
            let y = NSScreen.main!.frame.height - 25 - self.frame.height - 80
            self.setFrame(NSRect(origin: CGPoint(x: x, y: y), size: StateWindow.contentFrame.size), display: true)
        }
        if !self.isShowing {
            self.alphaValue = stateHudByMouse ? 1 : 0.9
            orderFront(self)
        }
        
        
        if needHide {
            self.hide(immediately: action == .hold(.up))
        }
        
    }
    
    func hide(immediately: Bool = false) {
        
        
        
        if !isShowing {
           return
        }
        

        if immediately {
            self.animator().alphaValue = 0
        } else {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: DispatchWorkItem(block: {
                self.animator().alphaValue = 0
            }))

        }
    }
    
    
    init() {
        
        
        super.init(contentRect: StateWindow.contentFrame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        
        
        
        ignoresMouseEvents = true
        
        isOpaque = false
        level = .statusBar
        hasShadow = false
        isReleasedWhenClosed = false
        alphaValue = 0
        
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        collectionBehavior.insert(.transient)
        backgroundColor = .clear
        
        imageView.image = NSImage(systemSymbolName: "opticaldiscdrive.fill", accessibilityDescription: nil)
        imageView.contentTintColor = .systemBlue
        imageView.symbolConfiguration = symbolConfiguration

        imageView.wantsLayer = true
        imageView.frame = StateWindow.contentFrame
        imageView.layer?.cornerRadius = 12
        contentView = imageView
        center()
        makeKey()
        orderFront(self)
    }
    
    var symbolConfiguration: NSImage.SymbolConfiguration {
        let pointSize: CGFloat = stateHudByMouse ? 25 : 100
        return NSImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
    }
    
    var stateHudByMouse: Bool {
        StateWindow.stateHudByMouse
    }
    
    static var contentFrame: NSRect {
        return  stateHudByMouse ?  NSRect(x: 0, y: 0, width: 50, height: 40) : NSRect(x: 0, y: 0, width: 200, height: 140)
    }
}
