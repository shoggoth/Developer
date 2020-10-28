//
//  SandwichStore.swift
//  Sandwiches
//
//  Created by Richard Henry on 18/08/2020.
//

import Foundation

class SandwichStore: ObservableObject {
    
    @Published var sandwiches: [Sandwich]
    
    init(sandwiches : [Sandwich] = []) {
        
        self.sandwiches = sandwiches
    }
}

let testStore = SandwichStore(sandwiches: testData)
