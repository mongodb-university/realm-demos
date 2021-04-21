//
//  ContentView.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var username = ""
    
    var body: some View {
        NavigationView {
            Group {
                if app.currentUser == nil {
                    LoginView(username: $username)
                } else {
                    InventoryView(username: $username)
                        .environment(\.realmConfiguration, app.currentUser!.configuration(partitionValue: store))
                }
            }
            .navigationBarTitle(username, displayMode: .inline)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
