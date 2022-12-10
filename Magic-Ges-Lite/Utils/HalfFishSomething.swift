//
//  HalfFishSomething.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/6.
//

import AppKit


class HalfFish {
    static func openHomePage() {
        openURLWith("https://wuyuezong.github.io")
    }
    
    static func openAboutPage() {
        openURLWith("https://wuyuezong.github.io/about")
    }
    
    static func openURLWith(_ string: String) {
        if let url = URL(string: string) {
            NSWorkspace.shared.open(url)
        }
    }
}
