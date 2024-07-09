//
//  ImmersiveView.swift
//  Two
//
//  Created by Takuya Nishimoto on 2024/06/26.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            // RealityKitコンテンツの追加
            if let scene = try? Entity.load(named: "ImmersiveScene", in: .main) {
                content.add(scene)
            }
        }
    }
}

// RealityKitContentバンドルの設定
private let realityKitContentBundle = Bundle.main.bundleURL.appendingPathComponent("RealityKitContent.rkassets")


#Preview(windowStyle: .volumetric) {
    ImmersiveView()
}
