//
//  InventoryLoginViewController.swift
//  InventoryDemo
//
//  Created by Paolo Manna on 07/10/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//

import RealmSwift
import UIKit

class InventoryLoginViewController: LoginViewController {
	@IBOutlet var storeNameField: AKFloatingLabelTextField!

	override func viewDidLoad() {
		super.viewDidLoad()

		storeNameField.delegate	= self
	}
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		storeNameField.text	= settings.storeName ?? store
	}
	
	override func setLoading(_ loading: Bool) {
		super.setLoading(loading)
		
		storeNameField.isEnabled	= !loading
	}
	
	override func completeSignIn(type: AuthType, user: User?, error: Error?) {
		if error == nil, let storeName = storeNameField.text, !storeName.isEmpty {
			settings.storeName	= storeName
			store				= storeName
		}
		
		super.completeSignIn(type: type, user: user, error: error)
	}
	
	// MARK: - UITextFieldDelegate
	
	override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField === usernameField {
			passwordField.becomeFirstResponder()
		} else if textField === passwordField {
			storeNameField.becomeFirstResponder()
		} else if textField === storeNameField {
			view.endEditing(true)
		}
		
		return false
	}
}
