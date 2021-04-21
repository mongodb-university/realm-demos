//
//  InventoryItem.swift
//  InventoryDemo
//
//  Created by Andrew Morgan on 21/04/2021.
//

import RealmSwift

@objcMembers class InventoryItem: Object, ObjectKeyIdentifiable {
    dynamic var _id = ObjectId.generate()
    dynamic var _partition: String = store
    dynamic var name = ""
    dynamic var price = 0.0
    dynamic var quantity = 0
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
}

extension InventoryItem {
    static var sample: InventoryItem {
        let sample = InventoryItem("Widget")
        sample.price = 9.99
        sample.quantity = 66
        return sample
    }
}
