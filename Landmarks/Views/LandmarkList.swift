//
//  LandmarkList.swift
//  Landmarks
//
//  Created by kyoneken on 2025/05/18.
//

import SwiftUI

struct LandmarkList: View {
    var body: some View {
//        // イテレートして表示
//        List(landmarks, id: \.id) { landmark in
//            LandmarkRow(landmark: landmark)
//        }
        
        // Identifiable準拠の場合
        NavigationSplitView {
            List(landmarks) { landmark in
                NavigationLink {
                    LandmarkDetail(landmark: landmark)
                } label: {
                    LandmarkRow(landmark: landmark)
                }
            }
            .navigationTitle("Landmarks")
        } detail: {
            Text("Select a Landmark")
        }
    }
}

#Preview {
    LandmarkList()
}
