//
//  TwoApp.swift
//  Two
//
//  Created by Takuya Nishimoto on 2024/06/26.
//

import SwiftUI

@main
struct TwoApp: App {
    var body: some Scene {
        WindowGroup {
            SwiftUIView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 0.01, in: .meters)
    }
}
