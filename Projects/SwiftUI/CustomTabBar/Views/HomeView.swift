//
//  HomeView.swift
//  CustomTabBar
//
//  Created by Richard Henry on 20/05/2021.
//

import SwiftUI

struct HomeView: View {
    
    @State var selectedTab = "house"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("TabBG")
                .ignoresSafeArea()
            TabBar(selectedTab: $selectedTab)
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
