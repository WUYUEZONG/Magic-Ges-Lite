//
//  ScrollWheelDelta.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/3.
//

import Foundation

struct ScrollWheelDirection: OptionSet {
    
    static let up = ScrollWheelDirection(rawValue: 1 << 0)
    
    static let down = ScrollWheelDirection(rawValue: 1 << 1)
    
    static let left = ScrollWheelDirection(rawValue: 1 << 2)
    
    static let right = ScrollWheelDirection(rawValue: 1 << 3)
    
    var rawValue: Int8
    
    init(rawValue: Int8) {
        self.rawValue = rawValue
    }
    
}

struct ScrollWheelDelta {
    var direction: ScrollWheelDirection?
    var maxValue: Double
}
