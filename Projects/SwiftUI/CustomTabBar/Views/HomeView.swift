//
//  HomeView.swift
//  CustomTabBar
//
//  Created by Richard Henry on 20/05/2021.
//

import SwiftUI

struct HomeView: View {
    
    let buttons = ["house", "bookmark", "message", "person", "heart"]
    
    @State var selectedTab = "bookmark"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("TabBG")
                .ignoresSafeArea()
            TabBar(buttons: buttons, selectedTab: $selectedTab)
                .padding(.bottom)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        HomeView()
            .preferredColorScheme(.dark)
    }
}
