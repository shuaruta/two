//
//  SwiftUIView.swift
//  Two
//
//  Created by Takuya Nishimoto on 2024/06/28.
//

import SwiftUI
import AudioToolbox // AudioToolboxをインポート

struct SwiftUIView: View {
    @State private var message1: String = "Hello, World!" // 上のテキストの状態を管理する
    @State private var message2: String = "Tap me!" // 下のテキストの状態を管理する
    @State private var dragOffset = CGSize.zero
    @State private var magnification: CGFloat = 1.0
    @State private var rotation: Angle = .zero
    @State private var depth: CGFloat = 0.0 // 奥行きを管理する状態変数

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.blue.opacity(0.5))
                    .frame(width: 200, height: 200)
                    .offset(z: 0)
                
                Text("前面のテキスト")
                    .offset(z: 100)
                    .onTapGesture {
                        // テキストがタップされたときのアクション
                        print("前面のテキストがタップされました")
                        playSystemSound(soundID: 1004) // カレンダーアラートのサウンドID
                    }
            }

            Text(message1)
                .font(.largeTitle) // フォントサイズを大きくする
                .padding(30) // パディングを追加

            Text(message2)
                .font(.largeTitle) // フォントサイズを設定
                .padding(30) // パディングを追加

            Rectangle()
                .fill(Color.blue)
                .frame(width: 500, height: 500)
                .hoverEffect(.automatic)
                .onTapGesture {
                    playSystemSound(soundID: 1004)
                }
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { _ in
                            dragOffset = .zero
                        }
                )
                .gesture(
                    LongPressGesture(minimumDuration: 1.0)
                        .onChanged { _ in
                            playSystemSound(soundID: 1004)
                        }
                        .onEnded { _ in
                            playSystemSound(soundID: 1004)
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            magnification = value
                        }
                )
                .scaleEffect(magnification)
                .gesture(
                    RotationGesture()
                        .onChanged { value in
                            rotation = value
                        }
                )
                .rotationEffect(rotation)

        }
    }
    
    private func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}


#Preview {
    SwiftUIView()
}
