//
//  LandmarksApp.swift
//  Landmarks
//
//  Created by kyoneken on 2025/05/17.
//

import SwiftUI

@main
struct LandmarksApp: App {
    @State private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
        }
    }
}
