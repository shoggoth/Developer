//
//  DepsychView.swift
//  Shared
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI

struct DepsychView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            Text("Depsych, world!")
                .padding()
        }
    }
}

struct DepsychView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            DepsychView()
        }
        .colorScheme(.light)
        TabView {
            DepsychView()
        }
        .colorScheme(.dark)
    }
}
