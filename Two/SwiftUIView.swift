//
//  SwiftUIView.swift
//  Two
//
//  Created by Takuya Nishimoto on 2024/06/28.
//

import SwiftUI

struct SwiftUIView: View {
    @State private var message1: String = "Hello, World!" // 上のテキストの状態を管理する
    @State private var message2: String = "Tap me!" // 下のテキストの状態を管理する

    var body: some View {
        VStack { // VStackを使用して垂直にビューを並べる
            Text(message1)
                .font(.largeTitle) // フォントサイズを大きくする
                .padding(30) // パディングを追加
                .hoverEffect(.automatic) // ホバーエフェクトを追加
                .onTapGesture {
                    // 上のテキストがタップされたときの処理
                    message1 = message1 == "Hello, World!" ? "Tapped!" : "Hello, World!"
                }

            Text(message2)
                .font(.largeTitle) // フォントサイズを設定
                .padding(30) // パディングを追加
                .hoverEffect(.automatic) // 別のホバーエフェクトを追加
                .onTapGesture {
                    // 下のテキストがタップされたときの処理
                    message2 = message2 == "Tap me!" ? "Tapped!" : "Tap me!"
                }
        }
    }
}


#Preview {
    SwiftUIView()
}
