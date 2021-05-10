//
//  InventoryDemoApp.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import SwiftUI
import RealmSwift

//let app = RealmSwift.App(id: "inventorysync-xxxx") // TODO: Set the Realm application ID
let appId = ProcessInfo.processInfo.environment["REALM_APP_ID"]
let app = RealmSwift.App(id: appId!)
var store = "101"

@main
struct InventoryDemoApp: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
