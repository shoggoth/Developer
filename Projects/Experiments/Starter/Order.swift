//
//  Order.swift
//  iDine
//
//  Created by Paul Hudson on 27/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import SwiftUI

class Order: ObservableObject {
    
    @Published var items = [MenuItem]()

    var total: Decimal { items.count > 0 ? items.reduce(0) { $0 + $1.price } : 0 }

    func add(item: MenuItem) { items.append(item) }

    func remove(item: MenuItem) { if let index = items.firstIndex(of: item) { items.remove(at: index) }}
}
