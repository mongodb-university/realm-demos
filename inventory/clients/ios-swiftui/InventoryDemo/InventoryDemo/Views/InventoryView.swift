//
//  InventoryView.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI
import RealmSwift

struct InventoryView: View {
    @ObservedResults(InventoryItem.self, sortDescriptor: SortDescriptor(keyPath: "name", ascending: true)) var items
    @Binding var username: String
    
    @State var showingNewItem = false
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                ForEach(items) { item in
                    ItemView(item: item)
                }
            }
            .padding()
            if let user = app.currentUser {
                NavigationLink(
                    destination: AddItemView()
                        .environment(\.realmConfiguration, user.configuration(partitionValue: store)),
                    isActive: $showingNewItem) {}
            }
        }
        .navigationBarTitle("Store \(store) Inventory", displayMode: .inline)
        .navigationBarItems(leading: Button(action: logout) { Text("Logout") },
                            trailing: Button(action: { showingNewItem.toggle() }) { Image(systemName: "plus") })
    }
    private func logout() {
        app.currentUser?.logOut() {_ in
            username = ""
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InventoryView(username: .constant("Billy"))
        }
    }
}
