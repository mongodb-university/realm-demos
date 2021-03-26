//
//  Settings.swift
//

import UIKit

@objc class Settings: NSObject {
	// Not used for simple types, avoids Codable decoding
	// for more complex objects that are accessed frequently
	var userDefaults: UserDefaults
	var cachedSettings	= [String: Codable]()
	
	init(with defaults: UserDefaults = UserDefaults.standard) {
		userDefaults	= defaults
	}
	
	override func value(forKey key: String) -> Any? {
		return userDefaults.object(forKey: key)
	}
	
	override func setValue(_ value: Any?, forKey key: String) {
		if value == nil {
			userDefaults.removeObject(forKey: key)
		} else {
			userDefaults.set(value!, forKey: key)
		}
	}
}

let settings	= Settings()

@objc class SharedSettings: Settings {
	init() {
		if let infoDict = Bundle.main.infoDictionary, let appGroup = infoDict["AppGroup"] as? String {
			super.init(with: UserDefaults(suiteName: appGroup)!)
		} else {
			super.init()
		}
	}
}

let sharedSettings	= SharedSettings()

/*
  * Usage within an app:
  *
 extension Settings {
 	var firstStartupCompleted: Bool {
 		get { return value(forKey: "FirstStartupCompleted") as? Bool ?? false }
 		set { setValue(newValue, forKey: "FirstStartupCompleted") }
 	}
	
 	var userName: String? {
 		get { return value(forKey: "UserName") as? String }
 		set { setValue(newValue, forKey: "UserName") }
 	}
 }
  */
