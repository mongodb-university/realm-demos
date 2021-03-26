//
//  Constants.swift
//  InventoryDemo
//
//  Created by Paolo Manna on 14/08/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//

import Foundation
import RealmSwift

struct Constants {
	// Set this to your Realm App ID found in the Realm UI.
	static let REALM_APP_ID = "inventorysync-cqhvc"
}

let app		= App(id: Constants.REALM_APP_ID)
var store	= "101"

var cleanDatabase	= false
