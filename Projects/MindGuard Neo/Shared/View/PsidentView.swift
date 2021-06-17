//
//  PsidentView.swift
//  Shared
//
//  Created by Richard Henry on 17/05/2021.
//

import SwiftUI

struct PsidentView: View {
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            Text("Psident, world!")
                .padding()
        }
    }
}

struct PsidentView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            PsidentView()
        }
        .colorScheme(.light)
        TabView {
            PsidentView()
        }
        .colorScheme(.dark)
    }
}
