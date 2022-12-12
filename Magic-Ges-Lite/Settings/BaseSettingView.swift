//
//  BaseSettingView.swift
//  MagicGesture
//
//  Created by iMac on 2022/12/5.
//

import SwiftUI
import LaunchAtLogin

struct BaseSettingView: View {
    
    @State var autoOpenWhenLaunch = false
    
    var isAXIsProcessTrusted = AXIsProcessTrusted()
    
    @State var longActionStepValue: Double = 0.4
    @State var sensitivitySlideValue: Double = 0.2
    
    var body: some View {
        List {
            
            Section {
                Group {
                    accessabilityItemView
                    
                    Divider()
                    
                    launchAtLoginItemView
                }
                .padding(.vertical, 10)
//                .overBorder()
                
            } header: {
                Text("Basic Settings")
            }
            
            Divider()
            
            Section {
                Group {
                    longHoldItemView
                    
                    Divider()
                    
                    sensitivityItemView
                    
                }
                .padding(.vertical, 10)
//                .overBorder()
            } header: {
                Text("Gesture Parameter Adjustment")
            }
            
            
            Divider()
            
            HStack {
                
                Text("👀 Check for updates:")
                
                Group {
                    Button {
                        HalfFish.openURLWith("https://github.com/WUYUEZONG/MagicGesturePackage/releases")
                    } label: {
                        HStack {
                            Text("GitHub")
                            Image(systemName: .link_icon)
                        }
                    }
                    .padding(.trailing, 15)
                    
                    Button {
                        HalfFish.openURLWith("https://gitee.com/rn-wyz/MagicGesturePackage/releases")
                    } label: {
                        HStack {
                            Text("Gitee")
                            Image(systemName: .link_icon)
                        }
                    }
                }
                .onHover(perform: { isOn in
                    isOn ? NSCursor.pointingHand.push() : NSCursor.pop()
                })
                .buttonStyle(.link)
            }
            
            
            
            
        }
        .navigationTitle("Settings")
        .onAppear {
            sensitivitySlideValue = WZMagicMouseHandle.shared.sensitivity
        }
        .listStyle(.sidebar)
    }
}


extension BaseSettingView {
    
    var accessabilityItemView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Current status")
                    .font(.headline)
                
                HStack {
                    Image(systemName: .circle_fill)
                        .foregroundColor(isAXIsProcessTrusted ? Color.green : .red)
                    Text(accessabilityStatusStringKey)
                        .fontWeight(.bold)
                        .foregroundColor(isAXIsProcessTrusted ? Color.green : .red)
                        
                    Text("You must turn on the auxiliary function to use gestures")
                }
                .tipFont()
            }
            
            Spacer()
            if !isAXIsProcessTrusted {
                Button("Go settings") {
                    NSWorkspace.shared.open(URL(string:"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                }
            }
        }
    }
    
    var launchAtLoginItemView: some View {
        LaunchAtLogin.Toggle {
            HStack {
                VStack(alignment: .leading, spacing: 8.0) {
                    Text("Login at Launch")
                        .font(.headline)
                    Text("Set the power on to start automatically. After restart, it is unnecessary to start manually, so that you can use gestures at any time")
                        .tipFont()
                }
                Spacer()
            }
        }
        .toggleStyle(.switch)
    }
    
    var longHoldItemView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Long press the gesture to start the delay time")
                    .font(.headline)
                Text("When you make a sliding gesture, do not release it. After a certain period of time, the gesture will become a long press gesture. See the gesture column for more details.")
                    .tipFont()
            }
            
            Spacer()
                
//                        Spacer(minLength: 100)
            
            Stepper {
                Text("\(longActionStepValue.formatted()) seconds")
            } onIncrement: {
                incrementStep()
            } onDecrement: {
                decrementStep()
            }
            .fixedSize()
        }
    }
    
    
    var sensitivityItemView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8.0) {
                Text("Gesture Sensitivity")
                    .font(.headline)
                Text("If you think the effect of gesture triggering does not meet your expectations, please raise it as much as possible")
                    .tipFont()
            }
            
            Spacer()
                
//                        Spacer(minLength: 100)
            
            Slider(value: $sensitivitySlideValue,
                   in: 0...0.6,
                   step: 0.1)
            {
//                            Text("\(sensitivitySlideValue.formatted())")
            } minimumValueLabel: {
                Text("High")
            } maximumValueLabel: {
                Text("Low")
            } onEditingChanged: { f in
                WZMagicMouseHandle.shared.sensitivity = sensitivitySlideValue
            }
            .frame(width: 150)

            
        }
    }
}

extension BaseSettingView {
    
    func stepperStep() -> Double {
        0.1
    }
    
    func miniStep() -> Double {
        0.3
    }
    func maxStep() -> Double {
        0.8
    }
    
    func incrementStep() {
        longActionStepValue += stepperStep()
        if longActionStepValue >= maxStep() { longActionStepValue = miniStep() }
        WZMagicMouseHandle.shared.becomeLongActionDelay = longActionStepValue
        
    }
    
    func decrementStep() {
        longActionStepValue -= stepperStep()
        if longActionStepValue < miniStep() { longActionStepValue = maxStep() }
        WZMagicMouseHandle.shared.becomeLongActionDelay = longActionStepValue
    }

    
    var accessabilityStatusStringKey: LocalizedStringKey {
        isAXIsProcessTrusted ? "On" : "Off"
    }
    
}

extension View {
    
    func overBorder() -> some View {
        overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.gray, lineWidth: 1)
        )
        .padding(1)
    }
    
    func tipFont() -> some View {
        font(.footnote)
        .foregroundColor(Color.gray)
    }
}

struct BaseSettingView_Previews: PreviewProvider {
    static var previews: some View {
        BaseSettingView()
            .environment(\.locale, Locale(identifier: "en"))
    }
}
