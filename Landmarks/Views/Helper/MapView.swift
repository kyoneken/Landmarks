//
//  MapView.swift
//  Landmarks
//
//  Created by kyoneken on 2025/05/17.
//

import SwiftUI
import MapKit

struct MapView: View {
    var coordinate: CLLocationCoordinate2D

    var body: some View {
//        Map(coordinateRegion: .constant(region))
//        Map(initialPosition: .region(region))
        Map(position: .constant(.region(region)))
    }
    
    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: coordinate,
            span: .init(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1)
        )
    }
}

#Preview {
    MapView(coordinate: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868))

}
