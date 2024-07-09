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
            // ImmersiveView()
            // ContentView()
            SwiftUIView()
        }.windowStyle(.volumetric)
    }
}
