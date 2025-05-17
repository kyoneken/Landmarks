//
//  MapView.swift
//  Landmarks
//
//  Created by kyoneken on 2025/05/17.
//

import SwiftUI
import MapKit

struct MapView: View {
    var body: some View {
        Map(coordinateRegion: .constant(region))
    }
    
    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: .init(
                latitude: 34.011_286,
                longitude: -116.166_868),
            span: .init(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1)
        )
    }
}

#Preview {
    MapView()
}
