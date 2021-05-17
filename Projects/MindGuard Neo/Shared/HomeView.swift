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
            ContentView()
                .tabItem { Label("Home", systemImage: "square.and.pencil") }
            ContentView()
                .tabItem { Label("Depsych", systemImage: "list.dash") }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
