//
//  DonateView.swift
//  Magic-Ges-Lite
//
//  Created by iMac on 2022/12/11.
//

import SwiftUI

struct DonateView: View {
    var body: some View {

        List {
            Text("Donate")
                .padding(.top, 50)
            
            HStack {
                Image("v5")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Image("zfb")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .listStyle(.sidebar)
    }
}

struct DonateView_Previews: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
