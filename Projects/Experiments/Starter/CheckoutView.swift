//
//  CheckoutView.swift
//  Starter
//
//  Created by Richard Henry on 18/05/2021.
//  Copyright © 2021 Dogstar Industries. All rights reserved.
//

import SwiftUI

struct CheckoutView: View {
    
    @EnvironmentObject var order: Order
    
    @State private var paymentType = "Cash"
    @State private var addLoyaltyDetails = false
    @State private var loyaltyNumber: String = ""
    @State private var tipAmount = 15
    
    var totalPrice: String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        let total = order.total
        let tipValue = total * Decimal(tipAmount) / 100

        return formatter.string(for: total + tipValue) ?? "0"
    }
    
    let paymentTypes = ["Cash", "Credit Card", "Dinning Points"]
    let tipAmounts = [10, 15, 20, 25, 0]
    
    var body: some View {
        Form {
            Section {
                Picker("How do you want to pay?", selection: $paymentType) {
                    ForEach(paymentTypes, id: \.self) { Text($0) }
                }
                Toggle("Add iDine loyalty card", isOn: $addLoyaltyDetails.animation())
                if addLoyaltyDetails { TextField("Enter your iDine ID", text: $loyaltyNumber) }
            }
            Section(header: Text("Add a tip?")) {
                Picker("Percentage:", selection: $tipAmount) {
                    ForEach(tipAmounts, id: \.self) { Text("\($0)%") }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("TOTAL: \(totalPrice)")) {
                Button("Confirm order") {
                    // place the order
                }
            }
        }
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CheckoutView().environmentObject(Order())
        }
    }
}
