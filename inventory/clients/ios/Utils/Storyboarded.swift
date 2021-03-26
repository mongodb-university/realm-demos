//
// Storyboarded.swift
// see: https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps
//

import UIKit

protocol Storyboarded {
	static func instantiate(storyboardName: String) -> Self
}

extension Storyboarded where Self: UIViewController {
	static func instantiate(storyboardName: String = "Main") -> Self {
		// this pulls out "MyApp.MyViewController"
		let fullName = NSStringFromClass(self)

		// this splits by the dot and uses everything after, giving "MyViewController"
		let className = fullName.components(separatedBy: ".")[1]

		// load our storyboard
		let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)

		// instantiate a view controller with that identifier, and force cast as the type that was requested
		return storyboard.instantiateViewController(withIdentifier: className) as! Self
	}
}
