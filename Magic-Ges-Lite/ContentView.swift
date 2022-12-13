//
//  ContentView.swift
//  MagicGesture
//
//  Created by iMac on 2022/12/5.
//

import SwiftUI



struct ContentView: View {
    
    @State var sideBarItems: [MGMenuItem] = [.home, .magicMouse, .about, .donate]
    
    @StateObject private var selectedItem = SideBarSeleted()
    
    var body: some View {
        contentBody()
            .environmentObject(selectedItem)
            
    }
}



extension ContentView {
    
    @ViewBuilder
    func detailView(_ menu: MGMenuItem?) -> some View {
        if menu == .home {
            BaseSettingView()
        } else if menu == .about {
            AboutAppView()
        } else if menu == .magicMouse {
            MagicMouseView()
        } else if menu == .donate {
            DonateView()
        } else {
            BaseSettingView()
        }
    }
    
    
    
    func navlinkLabel(item: MGMenuItem) -> some View {
        HStack {
            Image(systemName: item.image)
                .font(.headline)
                .frame(width: 26, height: 26)
//                                .padding(5)
//                .background(Color.accentColor)
                .cornerRadius(9)
                
            Text(item.name)
                .font(.headline)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
    }
    
    
    @ViewBuilder
    func contentBody() -> some View {
        if #available(macOS 13, *){
            NavigationSplitView {
                List(sideBarItems, id: \.id, selection: $selectedItem.item) { item in
                    NavigationLink(value: item) {
                        navlinkLabel(item: item)
                            .keyboardShortcut(KeyEquivalent(item.keyboardShortCut))
                    }
                }
//                .padding(.top, 20)
                .listStyle(.sidebar)

            } detail: {

                detailView(selectedItem.item)
                    .frame(minWidth: 400)
            }
        } else {
            NavigationView {
                
                List(sideBarItems, id: \.id) { item in
                    NavigationLink(tag: item, selection: $selectedItem.itemOrNil) {
                        detailView(selectedItem.itemOrNil)
                            .frame(minWidth: 400)
                    } label: {
                        navlinkLabel(item: item)
                    }
                }
//                .padding(.top, 20)
                .listStyle(.sidebar)
                
            }

        }
    }
}

