//
//  LocalizeExtensions.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/6.
//

import SwiftUI

extension String {
    
    /// 本地化
//    var localizedKey: LocalizedStringKey {
//        return LocalizedStringKey(self)
//    }
    
    //
    //
    // Settings
    //
    //
    
//    static let main_list_settings = "main_list_settings"
//
//    static let settings_accessability_status_title = "settings_accessability_status_title"
//    static let settings_accessability_status_on = "settings_accessability_status_on"
//    static let settings_accessability_status_off = "settings_accessability_status_off"
//    static let accessability_auth_des = "accessability_auth_des"
//
//    static let settings_login_at_launch_title = "settings_login_at_launch_title"
//    static let settings_login_at_launch_des = "settings_login_at_launch_des"
//
//    //
//    //
//    // Achievements
//    //
//    //
//
//    static let main_list_achievement = "main_list_achievement"
//
//
//    //
//    //
//    // maigc_mouse
//    //
//    //
//
//
//    static let main_list_maigc_mouse = "main_list_maigc_mouse"
//    static let magic_mouse_gesture_overview = "magic_mouse_gesture_overview"
//    static let magic_mouse_minimize_window_title = "magic_mouse_minimize_window_title"
//    static let magic_mouse_minimize_window_notes = "magic_mouse_minimize_window_notes"
//    static let magic_mouse_max_window_title = "magic_mouse_max_window_title"
//    static let magic_mouse_max_window_notes = "magic_mouse_max_window_notes"
//    static let magic_mouse_left_half_window_title = "magic_mouse_left_half_window_title"
//    static let magic_mouse_left_half_window_notes = "magic_mouse_left_half_window_notes"
//    static let magic_mouse_right_half_window_title = "magic_mouse_right_half_window_title"
//    static let magic_mouse_right_half_window_notes = "magic_mouse_right_half_window_notes"
//
//
//    //
//    //
//    // Help
//    //
//    //
//    static let main_list_help = "main_list_help"
//
//
//    //
//    //
//    // About
//    //
//    //
//
//    static let main_list_about = "main_list_about"
//    static let about_app_name_tip = "about_app_name_tip"
//    static let about_app_name = "about_app_name"
//    static let CFBundleDisplayName = "CFBundleDisplayName"
//
//
//    static let about_app_version_tip = "about_app_version_tip"
//    static let about_app_auth_tip = "about_app_auth_tip"
//    static let about_app_thanks_tip = "about_app_thanks_tip"
//    static let about_app_slogan = "about_app_slogan"
}


extension String {
    
    
    static func appVersion() -> String {
        if let info = Bundle.main.infoDictionary {
            return info["CFBundleShortVersionString"] as! String
        }
        return "1.0"
    }
}

