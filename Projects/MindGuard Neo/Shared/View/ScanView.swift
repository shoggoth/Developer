//
//  ScanView.swift
//  Shared
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI

struct ScanView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea(edges: .top)
            Text("Scan, world!")
                .padding()
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            ScanView()
        }
        .colorScheme(.light)
        TabView {
            ScanView()
        }
        .colorScheme(.dark)
    }
}
