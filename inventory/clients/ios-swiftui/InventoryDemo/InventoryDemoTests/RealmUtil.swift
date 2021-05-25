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
    
    // returns an in-memory Realm, not connected to sync (local), for testing purposes
    static func initRealm() -> Realm? {
        do {
            let configuration = Realm.Configuration(fileURL: nil,
                                                    inMemoryIdentifier: "test-realm",
                                                    syncConfiguration: nil,
                                                    encryptionKey: nil,
                                                    readOnly: false,
                                                    schemaVersion: 0,
                                                    migrationBlock: nil,
                                                    deleteRealmIfMigrationNeeded: true,
                                                    shouldCompactOnLaunch: nil,
                                                    objectTypes: nil)
            let realm = try Realm(configuration: configuration)
            return realm
        } catch {
            fatalError("Something bad happened while creating the Realm: \(error)")
        }
    }
}
