//
// Coordinator.swift
// see: https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps
//

import UIKit

protocol Coordinator {
	var childCoordinators: [Coordinator] { get set }
	var navigationController: NavigationControllerWithError { get set }

	func start()
}
