//
//  ItemDetailView.swift
//  Starter
//
//  Created by Richard Henry on 18/05/2021.
//  Copyright © 2021 Dogstar Industries. All rights reserved.
//

import SwiftUI

struct ItemDetailView: View {
    
    let item: MenuItem
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                Image(item.mainImage)
                    .resizable()
                    .scaledToFit()
                Text("Photo: \(item.photoCredit)")
                    .padding(5)
                    .background(Color(white: 0, opacity: 0.3))
                    .cornerRadius(3)
                    .font(.caption)
                    .foregroundColor(.white)
                    .offset(x: -5, y: -5)
            }
            Text(item.description)
                .padding()
            Spacer()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemDetailView(item: MenuItem.example)
        }
    }
}
