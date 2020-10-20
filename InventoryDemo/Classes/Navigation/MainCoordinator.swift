//
//  MainCoordinator.swift
//  InventoryDemo
//
//  Created by Paolo Manna on 14/08/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//

import RealmSwift
import UIKit

class MainCoordinator: NSObject, Coordinator {
	var childCoordinators = [Coordinator]()
	var navigationController: NavigationControllerWithError

	init(navigationController: NavigationControllerWithError) {
		self.navigationController = navigationController
	}

	func start() {
		app.syncManager.logLevel	= .info
		
		if let doCleanStr = ProcessInfo.processInfo.environment["CLEAN_REALM"], let doClean = Bool(doCleanStr) {
			cleanDatabase	= doClean
		}
		
		let vc = InventoryViewController.instantiate()
        
		vc.coordinator	= self
		
		navigationController.pushViewController(vc, animated: false)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.showLoginWindow()
		}
	}
	
	@IBAction func loginCompleted() {
		if let vc = navigationController.topViewController as? InventoryViewController {
			vc.loadFromDB()
		}
	}
	
	@IBAction func showLoginWindow() {
		let vc = LoginViewController.instantiate()
        
		vc.coordinator	= self
		
		navigationController.present(vc, animated: true) {
			// Something
		}
	}
	
	@IBAction func signOut() {
		let vc = LoginViewController.instantiate()
        
		vc.coordinator	= self
		vc.signOut()
		
		navigationController.present(vc, animated: true) {
			// Something
		}
	}
}
