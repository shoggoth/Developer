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
                .tabItem { Label("Scan", systemImage: "square.and.pencil") }
            HitmapView()
                .tabItem { Label("Hitmap", systemImage: "square.and.pencil") }
            DepsychView()
                .tabItem { Label("Depsych", systemImage: "list.dash") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "list.dash") }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
