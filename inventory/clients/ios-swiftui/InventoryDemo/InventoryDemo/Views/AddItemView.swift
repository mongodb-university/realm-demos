//
//  AddItemView.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI
import RealmSwift

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedResults(InventoryItem.self) var items
    
    @State var item = InventoryItem()
    @State private var priceBuffer = "0.00"
    @State private var quantityBuffer = "0"
    
    var body: some View {
        VStack {
            InputField(title: "New Product Name", text: $item.name)
            InputField(title: "Price", text: $priceBuffer, keyboardType: .decimalPad)
            InputField(title: "Quantity", text: $quantityBuffer, keyboardType: .numberPad)
        }
        .padding()
        .navigationBarTitle("New Inventory Item", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: save) { Text("Save") })
    }
    
    private func save() {
        item.price = Double(priceBuffer) ?? 0.00
        item.quantity = Int(quantityBuffer) ?? 0
        $items.append(item)
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddItemView()
        }
    }
}
