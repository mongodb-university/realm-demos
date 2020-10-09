//
//  Models.swift
//  InventoryDemo
//
//  Created by MongoDB on 2020-05-07.
//  Copyright © 2020 MongoDB, Inc. All rights reserved.
//

import Foundation
import RealmSwift

class InventoryItem: Object {
	@objc dynamic var _id = ObjectId.generate()
	@objc dynamic var _partition: String = store
	@objc dynamic var name: String = ""
	@objc dynamic var price: Double = 0.0
	@objc dynamic var quantity: Int = 0
	
	override static func primaryKey() -> String? {
		return "_id"
	}
    
	convenience init(name: String) {
		self.init()
		
		_partition = store
		self.name = name
	}
}
