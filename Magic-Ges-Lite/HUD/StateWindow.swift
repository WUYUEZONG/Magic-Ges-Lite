//
//  StateWindow.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/8.
//

import SwiftUI



class StateWindow: NSPanel {
    
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
        self.imageView.image = image
        if !self.isShowing {
            self.alphaValue = 1
            let p = NSEvent.mouseLocation
            let o = NSPoint(x: p.x - StateWindow.contentFrame.width / 2, y: p.y -  StateWindow.contentFrame.height / 2 )
            self.setFrame(NSRect(origin: o, size: self.frame.size), display: true)
            orderFront(self)
        
            let item = DispatchWorkItem {
                NSCursor.setHiddenUntilMouseMoves(true)
            }
//            DispatchQueue.main.async {
//                NSCursor.setHiddenUntilMouseMoves(true)
//            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: item)
            
//            NSCursor.hide()
        }
        
        
        
        
        if needHide {
            self.hide()
        }
        
    }
    
    func hide(immediately: Bool = false) {
        
//        NSCursor.setHiddenUntilMouseMoves(false)
//        NSCursor.unhide()
//        NSCursor.pop()
        
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
        
//        title = "Status"
        
        isOpaque = false
        level = .statusBar
        hasShadow = false
        isReleasedWhenClosed = false
        alphaValue = 0
//        worksWhenModal = true
//        becomesKeyOnlyIfNeeded = true
        
//        styleMask.insert(.fullSizeContentView)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        collectionBehavior.insert(.transient)
        backgroundColor = .clear
//        let c = Image(systemName: "opticaldiscdrive.fill").frame(minWidth: 50, minHeight: 50)
        
        imageView.image = NSImage(systemSymbolName: "opticaldiscdrive.fill", accessibilityDescription: nil)
        imageView.contentTintColor = .systemBlue
        imageView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 25, weight: .regular)
//        imageView.symbolConfiguration.
                
//        effectView.frame = StateWindow.contentFrame
//        effectView.material = .contentBackground
        
//        effectView.maskImage = imageView
        
        
        imageView.wantsLayer = true
        imageView.frame = StateWindow.contentFrame
        imageView.layer?.cornerRadius = 12
        contentView = imageView
        center()
        makeKey()
        orderFront(self)
    }
    
    static var contentFrame: NSRect {
        return NSRect(x: 0, y: 0, width: 50, height: 40)
    }
    
}
