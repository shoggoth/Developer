//
//  HomeView.swift
//  MindGuard Neo
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            ScanView()
                .tabItem { Label("Scan", systemImage: "viewfinder") }
            HitmapView()
                .tabItem { Label("Hitmap", systemImage: "map") }
            PsidentView()
                .tabItem { Label("Psident", systemImage: "calendar") }
            DepsychView()
                .tabItem { Label("Depsych", systemImage: "umbrella") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
