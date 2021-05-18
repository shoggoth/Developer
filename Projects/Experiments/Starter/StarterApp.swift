//
//  StarterApp.swift
//  Starter
//
//  Created by Richard Henry on 17/05/2021.
//  Copyright © 2021 Dogstar Industries. All rights reserved.
//

import SwiftUI

@main struct StarterApp: App {
    
    @StateObject var order = Order()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(order)
        }
    }
}
