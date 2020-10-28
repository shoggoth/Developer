//
//  ContentView.swift
//  Neumorph
//
//  Created by Richard Henry on 28/10/2020.
//  Copyright © 2020 Dogstar Industries. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    private let coolWhite = Color("CoolWhite")
    private let shadow = Color.black.opacity(0.2)
    private let hilite = Color.white.opacity(0.7)

    var body: some View {
        ZStack {
            coolWhite
            RoundedRectangle(cornerRadius: 25)
                .fill(coolWhite)
                .frame(width: 300, height: 300)
                .shadow(color: shadow, radius: 10, x: 10, y: 10)
                .shadow(color: hilite, radius: 10, x: -5, y: -5)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone SE (1st generation)")
    }
}
