//
//  ContentView.swift
//  Shared
//
//  Created by Richard Henry on 13/08/2020.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var store: SandwichStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.sandwiches) { sandwich in
                    SandwichCell(sandwich: sandwich)
                }
                .onMove(perform: moveSandwiches)
                .onDelete(perform: deleteSandwich)
                
                HStack {
                    Spacer()
                    Text("\(store.sandwiches.count) Sandwiches").foregroundColor(.secondary).font(.subheadline)
                    Spacer()
               }
            }.navigationTitle("Sandwiches")
            
            // Automatically removed on the iPhone, placeholder on the iPad and macOS in a split view
            Text("Select a butty lad")
        }
    }
}

extension ContentView {
    
    func makeSandwich() {
        
        withAnimation { store.sandwiches.append(Sandwich(name: "Patty Melt", ingredientCount: 3)) }
    }
    
    func moveSandwiches(from: IndexSet, to: Int) {
        
        withAnimation { store.sandwiches.move(fromOffsets: from, toOffset: to) }
    }
    
    func deleteSandwich(offSets: IndexSet) {
        
        withAnimation { store.sandwiches.remove(atOffsets: offSets) }
    }
}

struct SandwichCell: View {
    
    let sandwich: Sandwich
    
    var body: some View {
        NavigationLink(destination: SandwichDetail(sandwich: sandwich)) {
            Image(sandwich.thumbnailName)
                .cornerRadius(7)
            VStack(alignment: .leading) {
                Text(sandwich.name)
                Text("\(sandwich.ingredientCount) ingredients")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView(store: testStore)
    }
}
