//
//  MagicMouseView.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/6.
//

import SwiftUI

struct MagicMouseView: View {
    
    @AppStorage(UserDefaults.UserKey.longActionDelay.rawValue) var delayTime: Double = 0.4
    
    @Binding var selectMenu: MGMenuItem?
    
    var body: some View {
        List {
            
            HStack {
                Spacer()
                Image(systemName: "macwindow")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 170, alignment: .topLeading)
                    .padding(.top, 25)
                
                Spacer()
                
            }
            .frame(width: 500,height: 80, alignment: .top)
            .background(Color.accentColor)
            .cornerRadius(12)
            .padding(.top, 10)
                
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color.yellow)
                Text("It will cancel the actions after hold over \(WZMagicMouseHandle.shared.getCancelActionDelay().formatted()) seconds")
                    .font(.headline)
                    .fontWeight(.bold)
                    
                    
            }
            .padding(.top, 30)
            
            // 在菜单栏向下滑动
            Section {
                GestureInfoCellView(imageName: .down_minmize,
                                    tintColor: .yellow,
                                    title: "When the mouse hovers over the top of the window and slides down quickly, the window is minimized",
                                    detail: "Slide down to minimize the window")
                
                GestureInfoCellView(imageName: .up_fill_visiable,
                                    tintColor: .green,
                                    title: "When the mouse hovers over the top of the window and slides up quickly, the window is maximized",
                                    detail: "Slide up to maximize the window")
                
                GestureInfoCellView(imageName: .left_half,
                                    tintColor: .accentColor,
                                    title: "When the mouse hovers over the top of the window and swipes to the left, the trigger window alignment occupies the left side of the screen",
                                    detail: "Slide left to align the left half of the window")
                
                GestureInfoCellView(imageName: .right_half,
                                    tintColor: .accentColor,
                                    title: "When the mouse hovers over the top of the window and slides quickly to the right, the trigger window alignment occupies the right side of the screen",
                                    detail: "Slide right to align the right half of the window")
                
            } header: {
                Text("Gestures at a glance")
            }
            
            Section {
                GestureInfoCellView(imageName: .hold_down_close,
                                    tintColor: .red,
                                    title: "When the mouse hovers over the top of the window, slides down and hold \(delayString) seconds, then trigger gesture for close the window",
                                    detail: "slides down and hold, close the window")
                
                GestureInfoCellView(imageName: .hold_up_full_screen,
                                    tintColor: .green,
                                    title: "When the mouse hovers over the top of the window, slides up and hold \(delayString) seconds, then trigger gesture for full screen the window",
                                    detail: "slides up and hold, full screen the window")
                
                GestureInfoCellView(imageName: .hold_left_most_left,
                                    tintColor: .accentColor,
                                    title: "When the mouse hovers over the top of the window, slides left and hold \(delayString) seconds, The window occupies 7/8 on the left side of the screen.",
                                    detail: "slides left and hold, align left")
                
                GestureInfoCellView(imageName: .hold_right_most_right,
                                    tintColor: .accentColor,
                                    title: "When the mouse hovers over the top of the window, slides right and hold \(delayString) seconds, the window occupies 7/8 on the right side of the screen.",
                                    detail: "slides left and hold, align right")
                
            } header: {
                HStack {
                    Text("The gesture triggered by letting go after sliding and waiting for \(delayString) seconds")
                    Button {

                        $selectMenu.wrappedValue = .home
                        
                    } label: {
                        Text("delay time setting")
                    }
                    .buttonStyle(.link)
                    .onHover { isOn in
                        isOn ? NSCursor.openHand.push() : NSCursor.pop()
                    }

                }
                
            }
            
            // 在窗口导航栏位置向下滑动
        }
        .navigationTitle("Maigc Mouse")
        .listStyle(.sidebar)
        
    }
}

extension MagicMouseView {
    var delayString : String {
        delayTime.formatted()
    }
}

struct MagicMouseView_Previews: PreviewProvider {
    static var previews: some View {
        MagicMouseView(selectMenu: .constant(.home))
            .environment(\.locale, Locale(identifier: "en"))
            .frame(height: 1000)
    }
}
