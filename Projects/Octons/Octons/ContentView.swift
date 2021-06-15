//
//  ContentView.swift
//  Octons
//
//  Created by Richard Henry on 15/06/2021.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    private var scene: OctonScene {
        
        OctonScene()
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
