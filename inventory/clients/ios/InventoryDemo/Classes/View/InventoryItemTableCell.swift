//
//  InventoryItemTableCell.swift
//  InventoryDemo
//
//  Created by Paolo Manna on 07/10/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//

import Realm
import RealmSwift
import UIKit

class InventoryItemTableCell: UITableViewCell {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var priceLabel: UILabel!
	@IBOutlet var qtyLabel: UILabel!
	@IBOutlet var qtyStepper: UIStepper!
	
	weak var controller: InventoryViewController?
	
	var item: InventoryItem? {
		didSet {
			if item != nil {
				titleLabel.text			= item!.name
				priceLabel.text			= String(format: "Price: %.2f", item!.price)
				qtyLabel.text			= String(format: "Qty: %d", item!.quantity)
				qtyStepper.isEnabled	= true
				qtyStepper.value		= Double(item!.quantity)
			} else {
				titleLabel.text			= nil
				priceLabel.text			= nil
				qtyLabel.text			= nil
				qtyStepper.isEnabled	= false
				qtyStepper.value		= 0.0
			}
		}
	}
	
	// MARK: - Actions
	
	@IBAction func changeQuantity(_ stepper: UIStepper) {
		guard item != nil else { return }
		
		controller?.changeItemQuantity(quantity: Int(stepper.value), for: item!)
	}
	
	@IBAction func changePrice(_ button: UIButton) {
		guard item != nil else { return }
		
		controller?.changeItemPrice(for: item!)
	}
}
