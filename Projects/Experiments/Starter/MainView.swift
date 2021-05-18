//
//  MainView.swift
//  Starter
//
//  Created by Richard Henry on 18/05/2021.
//  Copyright © 2021 Dogstar Industries. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem { Label("Menu", systemImage: "list.dash") }
            OrderView()
                .tabItem { Label("Order", systemImage: "square.and.pencil") }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environmentObject(Order())
    }
}
