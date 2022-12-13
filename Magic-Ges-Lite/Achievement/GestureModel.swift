//
//  GestureModel.swift
//  Magic-Ges-Lite
//
//  Created by mntechMac on 2022/12/13.
//

import Foundation


struct GestureModel: Identifiable {
    
    let id = UUID()
    
    let date = Date()
    
    var type: StateAction
    
    var number: Int
    
    var application: String
    
}
