//
//  ContentView.swift
//  Shared
//
//  Created by Richard Henry on 28/06/2020.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            
            Spacer()
            VStack {
                Text("Hello, world!").padding()
                Text("Placeholder, lols")
            }.padding(.bottom, 50).padding(.leading, 50)
            
            Spacer()

            VStack {
                Button("Press Me To Foo", action: foo).padding()
                Button(action: foo) { Label("Another Way To Foo", systemImage:"hand.wave").padding() }
            }
            
            Spacer()
        }
    }
    
    private func foo() {
        
        print("foo!")
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}
