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
            GameView()
        }
        .defaultSize(width: 800, height: 600)
    }
}
