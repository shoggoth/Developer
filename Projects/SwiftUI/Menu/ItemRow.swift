//
//  ItemRow.swift
//  Starter
//
//  Created by Richard Henry on 17/05/2021.
//  Copyright © 2021 Dogstar Industries. All rights reserved.
//

import SwiftUI

struct ItemRow: View {
    
    let item: MenuItem

    var body: some View {
        HStack {
            Image(item.thumbnailImage)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.secondary, lineWidth: 2))
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.price.currencyString ?? "???")
            }
            Spacer()
            ForEach(item.restrictions, id: \.self) { restriction in
                modifier(RestrictionBullet(restriction: restriction))
            }
        }
    }
}

struct RestrictionBullet: ViewModifier {
    
    var restriction: String
    let colors: [String: Color] = ["D": .purple, "G": .black, "N": .red, "S": .blue, "V": .green]

    func body(content: Content) -> some View {
        Text(restriction)
            .font(.caption)
            .fontWeight(.black)
            .padding(5)
            .background(colors[restriction, default: .black])
            .clipShape(Circle())
            .foregroundColor(.white)
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
    }
}

struct ItemRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ItemRow(item: MenuItem.example)
        }
    }
}
