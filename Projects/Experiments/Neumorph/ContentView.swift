//
//  ContentView.swift
//  Neumorph
//
//  Created by Richard Henry on 28/10/2020.
//  Copyright © 2020 Dogstar Industries. All rights reserved.
//

import SwiftUI

private let coolWhite = Color("CoolWhite")

private extension LinearGradient {
    
    init(_ colours: Color ...) {
        
        self.init(gradient: Gradient(colors: colours), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
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
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                            )
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
