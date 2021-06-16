//
//  HitmapView.swift
//  Shared
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI

struct HitmapView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea(edges: .top)
            Text("Hitmap, world!")
                .padding()
        }
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
