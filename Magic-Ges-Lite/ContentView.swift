//
//  ContentView.swift
//  MagicGesture
//
//  Created by iMac on 2022/12/5.
//

import SwiftUI



struct ContentView: View {
    
    
//    var menus: [MGMenuItem] = [.home, .achievement, .magicMouse, .help, .about]
    @State var sideBarItems: [MGMenuItem] = [.home, .magicMouse, .about, .donate]
    
    @State var selectdSideBarItem: MGMenuItem?
//    @State var selectdMenuOld: MGMenuItem? = Binding(MG)
    
//    var open: () = WZMagicMouseHandle.shared.start()
    
    
    var body: some View {
        contentBody()
//            .scaledToFit()
            .onAppear {
                selectdSideBarItem = .home

            }
            
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
            MagicMouseView(selectMenu: $selectdSideBarItem)
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
                List(sideBarItems, id: \.id, selection: $selectdSideBarItem) { item in
                    NavigationLink(value: item) {
                        navlinkLabel(item: item)
                            .keyboardShortcut(KeyEquivalent(item.keyboardShortCut))
                    }


                }
                .listStyle(.sidebar)

            } detail: {

                detailView(selectdSideBarItem)
                    .frame(minWidth: 400)
            }

        } else {
            NavigationView {
                
                List(sideBarItems, id: \.id) { item in
                    
                    NavigationLink(tag: item, selection: $selectdSideBarItem) {
                        detailView(selectdSideBarItem)
                            .frame(minWidth: 400)
                    } label: {
                        navlinkLabel(item: item)
                    }
                }
                .listStyle(.sidebar)
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//            .environment(\.locale, Locale(identifier: "en"))
//    }
//}
