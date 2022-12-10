//
//  AboutAppView.swift
//  MagicGesture
//
//  Created by iMac on 2022/12/5.
//

import SwiftUI

struct AboutAppView: View {
    var body: some View {
        List {
            
            HStack {
                Spacer()
                VStack {
                    Group {
                        Image(.logo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(24)
                            
                        VStack(spacing: 6.0) {
                            Text("application name")
                                .tipFont()
                            Text("Magic Gesture")
                                .font(.title)
                            Text("Help you use the mouse management window more conveniently")
                                .font(.callout)
                        }
                        
                        VStack {
                            Text("current version")
                                .tipFont()
                            Text(String.appVersion())
                        }
                        
                        VStack {
                            Text("author")
                                .tipFont()
                            HStack {
                                Text("wuyuezong | a half fish")
                                    .font(.nickly(size: 18))
                                Button {
                                    HalfFish.openHomePage()
                                } label: {
                                    Image(systemName: .link_icon)
                                }
                                .buttonStyle(.link)
                                
                            }
                        }
                        
                        VStack {
                            Text("thanks")
                                .tipFont()
                            
                            ThanksItemView(name: "Rectangle", url: "https://github.com/rxhanson/Rectangle")

                            ThanksItemView(name: "LaunchAtLogin", url: "https://github.com/sindresorhus/LaunchAtLogin")
                            
                            ThanksItemView(name: "Nickainley-Normal", url: "https://www.dafont.com/nickainley.font")
                            
                        }
                    }
                        .padding(.bottom, 20)
                    
                    
                    
                }
                .padding()
            .padding(.top, 50)
                
                Spacer()
            }
        }
        .navigationTitle("About")
        .listStyle(.sidebar)
    }
}


struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
