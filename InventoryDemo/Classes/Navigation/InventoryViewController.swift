//
//  InventoryViewController.swift
//  InventoryDemo
//
//  Created by Paolo Manna on 14/08/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//

import Realm
import RealmSwift
import UIKit

class InventoryViewController: UITableViewController, Storyboarded {
	weak var coordinator: MainCoordinator?
	
	var realm: Realm!
	var items: Results<InventoryItem>!
	var notificationToken: NotificationToken?
	
	@IBOutlet var logInOutButton: UIBarButtonItem!
	@IBOutlet var addButton: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		logInOutButton						= UIBarButtonItem(title: "Log In", style: .plain, target: self, action: #selector(logOutButtonDidClick))
		navigationItem.leftBarButtonItem	= logInOutButton

		addButton							= UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
		addButton.isEnabled					= false
		navigationItem.rightBarButtonItem	= addButton
		
		tableView.tableFooterView	= UIView(frame: .zero)
	}
	
	// MARK: - Actions
    
	func loadFromDB() {
		let nav	= navigationController as? NavigationControllerWithError
		
		if realm == nil {
			guard let user = app.currentUser else {
				nav?.postErrorMessage(message: "Must be logged in to access this view", isError: true)
				
				return
			}
			
			let config	= user.configuration(partitionValue: store)
			
			// Open a realm with the partition key set to the store.
			do {
				// Sample code to have a local DB reset
				if cleanDatabase {
					_	= try Realm.deleteFiles(for: config)
				}
				
				realm = try Realm(configuration: config)
			} catch {
				nav?.postErrorMessage(message: error.localizedDescription, isError: true)
				
				return
			}
		}
		
		logInOutButton.title	= "Log Out"
		addButton.isEnabled		= true
		
		// Access all objects in the realm, sorted by _id so that the ordering is defined.
		items = realm.objects(InventoryItem.self).sorted(byKeyPath: "_id")

		guard items != nil else {
			nav?.postErrorMessage(message: "No items found", isError: true)
			
			return
		}
		
		// Observe the items for changes.
		notificationToken = items.observe { [weak self] changes in
			guard let tableView = self?.tableView else { return }
			switch changes {
			case .initial:
				// Results are now populated and can be accessed without blocking the UI
				tableView.reloadData()
			case let .update(_, deletions, insertions, modifications):
				// Query results have changed, so apply them to the UITableView.
				tableView.beginUpdates()
				// It's important to be sure to always update a table in this order:
				// deletions, insertions, then updates. Otherwise, you could be unintentionally
				// updating at the wrong index!
				tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
				                     with: .automatic)
				tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
				                     with: .automatic)
				tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
				                     with: .automatic)
				tableView.endUpdates()
			case let .error(error):
				// An error occurred while opening the Realm file on the background worker thread
				nav?.postErrorMessage(message: error.localizedDescription, isError: true)
			}
		}
	}
	
	@IBAction func logOutButtonDidClick() {
		if realm == nil {
			coordinator?.showLoginWindow()
		} else {
			let alertController = UIAlertController(title: "Log Out", message: "", preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: "Yes, Log Out", style: .destructive, handler: { _ -> Void in
				app.currentUser?.logOut(completion: { [weak self] _ in
					self?.notificationToken?.invalidate()
					self?.notificationToken	= nil
					self?.realm				= nil
					self?.items				= nil
					
					DispatchQueue.main.sync { [weak self] in
						self?.tableView.reloadData()
						
						self?.logInOutButton.title	= "Log In"
						self?.addButton.isEnabled	= false
						self?.coordinator?.signOut()
					}
				})
			}))
			alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			present(alertController, animated: true, completion: nil)
		}
	}
    
	@IBAction func addButtonDidClick() {
		guard realm != nil else { return }
		
		// User clicked the add button.
        
		let alertController = UIAlertController(title: "Add New Product", message: "", preferredStyle: .alert)

		alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ -> Void in
			guard let self = self else { return }
			
			let nameStr = (alertController.textFields![0] as UITextField).text ?? "New Product"
			let priceStr = (alertController.textFields![1] as UITextField).text
			let qtyStr = (alertController.textFields![2] as UITextField).text
			
			let item = InventoryItem(name: nameStr)
			
			if priceStr != nil, !priceStr!.isEmpty {
				item.price = Double(priceStr!) ?? 0.0
			}
			if qtyStr != nil, !qtyStr!.isEmpty {
				item.quantity = Int(qtyStr!) ?? 0
			}
			
			// All writes must happen in a write block.
			try! self.realm.write {
				self.realm.add(item)
			}
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
			textField.placeholder = "New Product Name"
		})
		alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
			textField.placeholder = "Price"
		})
		alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
			textField.placeholder = "Quantity"
		})
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func changeItemQuantity(quantity: Int, for item: InventoryItem) {
		try! realm.write {
			item.quantity	= quantity
		}
	}
	
	@IBAction func changeItemPrice(for item: InventoryItem) {
		let alertController = UIAlertController(title: "Product Price", message: "Change the price", preferredStyle: .alert)

		alertController.addAction(UIAlertAction(title: "Change", style: .default, handler: { [weak self] _ -> Void in
			guard let self = self else { return }
			
			let textField	= alertController.textFields![0] as UITextField
			let priceStr	= textField.text ?? "0.0"
			let newPrice	= Double(priceStr) ?? 0.0
			
			try! self.realm.write {
				item.price	= abs(newPrice)
			}
		}))
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
			textField.placeholder	= "New Product Price"
			textField.text			= String(format: "%.2f", item.price)
		})
		present(alertController, animated: true, completion: nil)
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		
		if let itemList = items, !itemList.isEmpty {
			let itemCell	= tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! InventoryItemTableCell
			
			itemCell.item		= itemList[indexPath.row]
			itemCell.controller	= self
			
			cell				= itemCell
		} else {
			cell	= tableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath)
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		if let itemList = items, !itemList.isEmpty {
			return true
		}
		return false
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		
		// The user can swipe to delete Projects.
		let anItem = items[indexPath.row]
		
		// All modifications must happen in a write block.
		try! realm.write {
			// Delete the project.
			realm.delete(anItem)
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
