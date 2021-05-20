//
//  ContentView.swift
//  Neumorph
//
//  Created by Richard Henry on 20/05/2021.
//

import SwiftUI
import Neumorphic

struct ContentView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20).fill(Color.Neumorphic.main).softOuterShadow()
            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView()
            .preferredColorScheme(.dark)
    }
}
