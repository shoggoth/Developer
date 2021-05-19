//
//  MenuApp.swift
//  Menu
//
//  Created by Richard Henry on 19/05/2021.
//

import SwiftUI

@main struct MenuApp: App {
    
    @StateObject var order = Order()
    
    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(order)
        }
    }
}
