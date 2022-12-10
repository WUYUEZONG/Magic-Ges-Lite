//
//  ThanksItemView.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/8.
//

import SwiftUI

struct ThanksItemView: View {
    
    var name: String
    var url: String
    
    var body: some View {
        HStack {
            Text(name)
            Button {
                HalfFish.openURLWith(url)
            } label: {
                Image(systemName: .link_icon)
            }
            .buttonStyle(.link)
        }
    }
}

struct ThanksItemView_Previews: PreviewProvider {
    static var previews: some View {
        ThanksItemView(name: "LaunchAtLogin", url: "https://github.com/sindresorhus/LaunchAtLogin")
    }
}
