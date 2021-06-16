//
//  SettingsView.swift
//  Shared
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea(edges: .top)
            Text("Settings, world!")
                .padding()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            SettingsView()
        }
        .colorScheme(.light)
        TabView {
            SettingsView()
        }
        .colorScheme(.dark)
    }
}
