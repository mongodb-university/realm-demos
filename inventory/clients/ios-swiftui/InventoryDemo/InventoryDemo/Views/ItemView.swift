//
//  ItemView.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI
import RealmSwift

struct ItemView: View {
    @ObservedRealmObject var item: InventoryItem
    
    @State private var showingPriceEditor = false
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        Text("\(item.name)")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        // TODO: Need to be able to edit the price
                        Text("Price: \(item.price, specifier: "%.2f")")
                        Spacer()
                        Button(action : { showingPriceEditor.toggle() }) {
                            Image(systemName: "pencil")
                        }
                    }
                    .foregroundColor(.secondary)
                }
                CountStepper(label: "Qty", value: $item.quantity)
            }
            Divider()
        }
        .sheet(isPresented: $showingPriceEditor) {
            PriceInput(price: $item.price)
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(item: .sample)
    }
}
