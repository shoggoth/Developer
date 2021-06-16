//
//  HitmapView.swift
//  Shared
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI
import MapKit

struct HitmapView: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.96, longitude: -1.07), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region)
            Button("Zoom") {
                region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            }
            .padding()
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct HitmapView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            HitmapView()
        }
        .colorScheme(.light)
        TabView {
            HitmapView()
        }
        .colorScheme(.dark)
    }
}
