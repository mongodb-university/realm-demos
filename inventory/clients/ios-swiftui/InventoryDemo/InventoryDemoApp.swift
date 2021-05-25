//
//  InventoryDemoApp.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI
import RealmSwift

let (success, filecontent) = readFile(named: "realm-app-id.txt")

let app = RealmSwift.App(id: success ? filecontent: "Couldn't read secrets file. Is there?" )
var store = "101"

@main
struct InventoryDemoApp: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
