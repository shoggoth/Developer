//
//  SettingsView.swift
//  Shared
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI

#if os(macOS)
typealias PlatformListStyle = PlainListStyle
#else
typealias PlatformListStyle = GroupedListStyle
#endif

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Section 1"), footer: Text("lol faggot").font(.caption)) {
                    NavigationLink(destination: Text("foo")) {
                        SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    }
                    NavigationLink(destination: Text("bar")) {
                        SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    }
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                }
                Section(header: Text("Section 2"), footer: Text("lol lamer").font(.caption)) {
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                    SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
                }
            }
            .navigationTitle("Settings")
            .listStyle(PlatformListStyle())
        }
        .ignoresSafeArea()
    }
}

struct SettingsCell: View {
    
    let title: String
    let image: Image
    let colour: Color
    
    var body: some View {
        HStack {
            image
                .font(.headline)
                .foregroundColor(colour)
            Text(title)
                .padding(.leading, 9)
            Spacer()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCell(title: "Settings Cell", image: Image(systemName: "house"), colour: .primary)
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
