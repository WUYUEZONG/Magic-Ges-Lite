//
//  StateAction.swift
//  MagicGesture
//
//  Created by iMac on 2022/12/10.
//

import AppKit

enum StateAction: Equatable {
    
    enum Direction {
        case up
        case down
        case left
        case right
        case none
        
        var imageName: String {
            switch self {
            case .left:
                return .left_half
            case .right:
                return .right_half
            default: return .action_cancel
            }
        }
        
        var style: (bg: NSColor, tint: NSColor) {
            switch self {
            case .left, .right:
                return (NSColor.systemBlue, NSColor.white)
            default: return (NSColor.systemGray, NSColor.white)
            }
        }
        
        var frame: CGRect? {
            
            switch self {
            case .left:
                return .leftHalf
            case .right:
                return .rightHalf
            default:
                return nil
            }
        }
    }
    
    case none
    case normal(_ direct: Direction = .none)
    case hold(_ direct: Direction = .none)
    case exitFullScreen
    case cancel
    
    
    
    var imageName: String {
        switch self {
        case let .normal(direct):
            
            switch direct {
            case .up:
                return .up_fill_visiable
            case .down:
                return .down_minmize
            default: return direct.imageName
            }
            
        case let .hold(direct):
            switch direct {
            case .up:
                return .hold_up_full_screen
            case .down:
                return .hold_down_close
            case .left:
                return .hold_left_most_left
            case .right:
                return .hold_right_most_right
            default: return direct.imageName
            }
        case .exitFullScreen:
            return .exit_full_screen
        default:
            return .action_cancel
        }
    }
    
    var frame: CGRect? {
        
        switch self {
        case let .normal(direct):
            switch direct {
            case .up:
                return .visiableMax
            default: return direct.frame
            }
        case let .hold(direct):
            
            switch direct {
            case .left:
                return .mostLeft
            case .right:
                return .mostRight
            default: return direct.frame
            }
        default:
            return nil
        }
    }
    
    var style: (bg: NSColor, tint: NSColor) {
        
        switch self {
        case let .normal(direct):
            switch direct {
            case .up:
                return (NSColor.systemGreen, NSColor.white)
            case .down:
                return (NSColor.systemYellow, NSColor.white)
            default: return direct.style
            }
            
        case let .hold(direct):
            switch direct {
            case .up:
                return (NSColor.systemGreen, NSColor.white)
            case .down:
                return (NSColor.systemRed, NSColor.white)
            default: return direct.style
            }
            
        case .exitFullScreen:
            return (NSColor.systemRed, NSColor.white)
        default:
            return (NSColor.systemGray, NSColor.white)
        }
        
    }
    
}
