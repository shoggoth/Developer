//
//  ContentView.swift
//  Neumorph
//
//  Created by Richard Henry on 28/10/2020.
//  Copyright © 2020 Dogstar Industries. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color("CoolWhite")
            RoundedRectangle(cornerRadius: 25)
                .frame(width: 300, height: 300)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone SE (1st generation)")
    }
}
