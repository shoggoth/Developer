//
//  ContentView.swift
//  Neumorph
//
//  Created by Richard Henry on 28/10/2020.
//  Copyright © 2020 Dogstar Industries. All rights reserved.
//

import SwiftUI

private let coolWhite = Color("CoolWhite")

struct NeuButtonStyle: ButtonStyle {
    
    private let shadow = Color("Shadow")
    private let hilite = Color("Hilite")
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(23)
            .contentShape(Circle())
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(coolWhite)
                            .shadow(color: shadow, radius: 10, x: -5, y: -5)
                            .shadow(color: hilite, radius: 10, x: 10, y: 10)
                    } else {
                        Circle()
                            .fill(coolWhite)
                            .shadow(color: shadow, radius: 10, x: 10, y: 10)
                            .shadow(color: hilite, radius: 10, x: -5, y: -5)
                    }
                }
            )
    }
}

struct ContentView: View {
    
    var body: some View {
        ZStack {
            coolWhite
            Button(action: { print("button") }, label: {
                Image(systemName: "heart.fill")
                    .foregroundColor(.gray)
            }).buttonStyle(NeuButtonStyle())
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone SE (1st generation)")
    }
}
