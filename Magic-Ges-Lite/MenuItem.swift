//
//  MenuItem.swift
//  MagicGesture
//
//  Created by iMac on 2022/12/5.
//

import Foundation
import SwiftUI

class SideBarSeleted: ObservableObject {
    
    @Published var item: MGMenuItem = .home
    @Published var itemOrNil: MGMenuItem? = .home
    
    func updateItem(_ item: MGMenuItem = .home) {
        if #available(macOS 13, *) {
            self.item = item
        } else {
            self.itemOrNil = item
        }
    }
}

struct MGMenuItem : Hashable, Identifiable {
    
    func hash(into hasher: inout Hasher) {
//        hash(into: &hasher)
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    
    let name: LocalizedStringKey
    let image: String
    let keyboardShortCut: Character
    
    
    
}


extension MGMenuItem {
    ///
    static let home = MGMenuItem(name: "Settings", image: "person.circle.fill", keyboardShortCut: "1")
    static let achievement = MGMenuItem(name: "Achievements", image: "gamecontroller.fill", keyboardShortCut: "2")
    static let magicMouse = MGMenuItem(name: "Maigc Mouse", image: "magicmouse.fill", keyboardShortCut: "3")
    static let help = MGMenuItem(name: "Help", image: "questionmark.circle.fill", keyboardShortCut: "4")
    static let about = MGMenuItem(name: "About", image: "info.circle.fill", keyboardShortCut: "5")
    static let donate = MGMenuItem(name: "Donate", image: "dollarsign.circle.fill", keyboardShortCut: "6")
}
