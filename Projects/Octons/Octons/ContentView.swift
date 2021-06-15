//
//  ContentView.swift
//  Octons
//
//  Created by Richard Henry on 15/06/2021.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @State var octonFrame: CGSize = .zero
    
    private func makeOctonView(geometry: GeometryProxy) -> some View {
        
        DispatchQueue.main.async { self.octonFrame = geometry.size }
        
        return SpriteView(scene: SKScene(fileNamed: "OctonScene")!)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                makeOctonView(geometry: geometry)
            }
            .ignoresSafeArea()
            ZStack {
                //Color.red
                Text("Hello, world")
                    .font(.headline)
                    .padding()
            }
        }
        .statusBar(hidden: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
