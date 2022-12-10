//
//  GestureInfoCellView.swift
//  MagicGesture
//
//  Created by mntechMac on 2022/12/6.
//

import SwiftUI

struct GestureInfoCellView: View {
    
    var imageName: String
    var tintColor: Color
    var title: LocalizedStringKey
    var detail: LocalizedStringKey
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.title)
                .frame(width: 56, height: 56)
                .background(tintColor)
                .cornerRadius(10)
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 2.0) {
                Text(title)
                    .foregroundColor(.gray)
                Text(detail)
                    .foregroundColor(tintColor)
            }
        }
        .padding(.vertical, 10)
    }
}

struct GestureInfoCellView_Previews: PreviewProvider {
    static var previews: some View {
        GestureInfoCellView(imageName: .down_minmize,
                            tintColor: .yellow,
                            title: "当鼠标悬停于窗口顶部，向下快速滑动，触发窗口最小化",
                            detail: "当鼠标悬停于窗口顶部，向下快速滑动，触发窗口最小化")
    }
}
