//
//  SandwichesApp.swift
//  Shared
//
//  Created by Richard Henry on 13/08/2020.
//

import SwiftUI

@main struct SandwichesApp: App {
    
    @StateObject private var store = SandwichStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
