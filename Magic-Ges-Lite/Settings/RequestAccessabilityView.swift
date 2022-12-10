//
//  RequestAccessabilityView.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/6.
//

import SwiftUI

struct RequestAccessabilityView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 25.0) {
            
            Text("Authorize MagicGesture")
                .font(.largeTitle)
            
            Image(systemName: "info.circle")
                .font(.largeTitle)
            
            Text("MagicGesture needs your permission to control your window actions")
            
            Text("Go to System Preferences -> Security & Privacy -> Privacy -> Accessibility")
            
            Button("Open System Preferences") {
                WZMagicMouseHandle.openAccessabilityWindow()
            }
            .background(Color.accentColor)
            .keyboardShortcut(.return)
            
            Text("Enable MagicGesture.app")
            
            Text("If the checkbox is disabled, click the padlock and enter your password")
                .font(.callout)
            
        }
        .multilineTextAlignment(.center)
//        .frame(width: 300, height: 500)
        .padding()
        .padding()
//        .background(Color("Background"))
        .cornerRadius(12)
        .shadow(radius: 6)
        
        
    }
}

struct RequestAccessabilityView_Previews: PreviewProvider {
    static var previews: some View {
        RequestAccessabilityView()
    }
}
