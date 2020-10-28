//
//  Sandwich.swift
//  Sandwiches
//
//  Created by Richard Henry on 13/08/2020.
//

import Foundation

struct Sandwich: Identifiable {
    
    var id = UUID()
    var name: String
    var ingredientCount: Int
    var isSpicy: Bool = false
    
    var imageName: String { return name }
    var thumbnailName: String { return name + "-Thumbnail" }
}

let testData = [
//    Sandwich(name: "Club", ingredientCount: 4, isSpicy: false),
//    Sandwich(name: "Pastrami on Rye", ingredientCount: 4, isSpicy: true),
//    Sandwich(name: "French dip", ingredientCount: 3, isSpicy: false),
//    Sandwich(name: "Bahn mi", ingredientCount: 5, isSpicy: true),
//    Sandwich(name: "Ice cream sandwich", ingredientCount: 2, isSpicy: false),
//    Sandwich(name: "Croque monsieur", ingredientCount: 4, isSpicy: false),
//    Sandwich(name: "Hot dog", ingredientCount: 2, isSpicy: true),
//    Sandwich(name: "Fluffernutter", ingredientCount: 2, isSpicy: false),
//    Sandwich(name: "Avocado toast", ingredientCount: 3, isSpicy: true),
//    Sandwich(name: "Gua bao", ingredientCount: 4, isSpicy: true),
//    Sandwich(name: "Avocado Crepe", ingredientCount: 3, isSpicy: false),
//    Sandwich(name: "Sweet Chilli Veggie Mince Wrap", ingredientCount: 8, isSpicy: false),
    Sandwich(name: "California Quinoa Burger", ingredientCount: 5, isSpicy: false),
    Sandwich(name: "Caprese", ingredientCount: 4, isSpicy: false),
    Sandwich(name: "Double Wrap Bean Tacos", ingredientCount: 7, isSpicy: true),
    Sandwich(name: "Egg & Ham Openface", ingredientCount: 3, isSpicy: false),
    Sandwich(name: "Green Goddess Pita", ingredientCount: 4, isSpicy: false),
    Sandwich(name: "Grilled White Cheese", ingredientCount: 3, isSpicy: false),
    Sandwich(name: "Northern Soul Grilled Cheese", ingredientCount: 5, isSpicy: true),
    Sandwich(name: "Toasted Ham and Cheese", ingredientCount: 3, isSpicy: false),
    Sandwich(name: "Triple Meat & Cheese", ingredientCount: 6, isSpicy: true),
    Sandwich(name: "Vegan Blackbean Burger", ingredientCount: 5, isSpicy: true)
]
