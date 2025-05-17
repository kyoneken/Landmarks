//
//  CircleImage.swift
//  Landmarks
//
//  Created by kyoneken on 2025/05/17.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
        Image("turtlerock")
//            .resizable() // 他の画像を使った場合のリサイズ
//            .scaledToFit()
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
                    .shadow(radius: 7)
            }
    }
}

#Preview {
    CircleImage()
}
