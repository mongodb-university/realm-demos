//
//  PriceInput.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI

struct PriceInput: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var price: Double
    
    @State private var buffer = "0.00"
    
    var body: some View {
        NavigationView {
            InputField(title: "Price", text: $buffer, keyboardType: .decimalPad)
            .navigationBarTitle("Edit Price", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: saveAndClose) {
                Text("Save")
            })
            .onAppear() { buffer = String(price) }
                .padding()
        }
    }
    
    private func saveAndClose() {
        price = Double(buffer) ?? price
        presentationMode.wrappedValue.dismiss()
    }
}

struct PriceBindingView: View {
    @State var value: Double
    
    var body: some View {
        PriceInput(price: $value)
    }
}

struct PricePriceInput_Previews: PreviewProvider {
    static var previews: some View {
        PriceBindingView(value: 4.99)
    }
}
