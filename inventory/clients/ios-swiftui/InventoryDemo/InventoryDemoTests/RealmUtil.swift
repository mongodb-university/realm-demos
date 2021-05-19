//
//  RealmUtil.swift
//  InventoryDemoTests
//
//  Created by Diego Freniche Brito on 20/02/2021.
//


import Foundation
import RealmSwift

enum RealmUtil {
    static let realm: Realm? = initRealm()
    
    static func initRealm() -> Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
            fatalError("Something bad happened: \(error)")
        }
    }
}
