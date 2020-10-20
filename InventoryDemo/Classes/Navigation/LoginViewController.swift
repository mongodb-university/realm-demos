//
//  LoginViewController.swift
//  InventoryDemo
//
//  Created by Paolo Manna on 17/08/2020.
//  Copyright © 2020 MongoDB. All rights reserved.
//

import RealmSwift
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, Storyboarded {
	static let emailCheck = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
	
	enum AuthType {
		case none
		case anonymous
		case emailPassword
		case google
		case facebook
	}
	
	weak var coordinator: MainCoordinator?
	
	@IBOutlet var usernameField: AKFloatingLabelTextField!
	@IBOutlet var passwordField: AKFloatingLabelTextField!
	@IBOutlet var signInButton: UIButton!
	@IBOutlet var signUpButton: UIButton!
	@IBOutlet var anonymousSignInButton: UIButton?
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	var keychainItem: KeychainPasswordItem!
	var authType: AuthType	= .none
	var username: String? { usernameField.text }
	var password: String? { passwordField.text }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		usernameField.delegate	= self
		passwordField.delegate	= self
	}
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		usernameField.text	= settings.userName
		if let username = settings.userName {
			keychainItem	= KeychainPasswordItem(service: Constants.REALM_APP_ID, account: username)
			
			passwordField.text	= try? keychainItem.readPassword()
		}
		
		// Force validation if there's a value around
		if let name = usernameField.text, !name.isEmpty {
			_	= textField(usernameField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
		} else {
			signInButton.isEnabled	= false
			signUpButton.isEnabled	= false
		}
	}
	
	// MARK: - Utils
	
	// Turn on or off the activity indicator.
	func setLoading(_ loading: Bool) {
		if loading {
			activityIndicator.startAnimating()
		} else {
			activityIndicator.stopAnimating()
		}
		usernameField.isEnabled				= !loading
		passwordField.isEnabled				= !loading
		signInButton.isEnabled				= !loading
		signUpButton.isEnabled				= !loading
		anonymousSignInButton?.isEnabled	= !loading
	}

	func updateKeychain() {
		settings.userName	= username
		if let username = settings.userName, let password = password {
			do {
				if keychainItem != nil {
					if keychainItem.account != username {
						try keychainItem.renameAccount(username)
					}
				} else {
					keychainItem	= KeychainPasswordItem(service: Constants.REALM_APP_ID, account: username)
				}
				try keychainItem.savePassword(password)
			} catch  {
				// Do something?
			}
		}
	}
	
	func showAlert(title: String, message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
		present(alertController, animated: true, completion: nil)
	}
	
	func showErrorAlert(message: String) {
		showAlert(title: "Error", message: message)
	}
	
	func completeSignIn(type: AuthType, user: RealmSwift.User?, error: Error?) {
		setLoading(false)
		
		guard error == nil else {
			showErrorAlert(message: "Login failed: \(error!.localizedDescription)")
			return
		}
		
		guard user != nil else {
			showErrorAlert(message: "Invalid User")
			return
		}
		
		authType	= type
		dismiss(animated: true) { [weak self] in
			self?.coordinator?.loginCompleted()
		}
	}
	
	// MARK: - Actions
	
	@IBAction func anonymousSignIn(_ sender: UIButton) {
		setLoading(true)
		app.login(credentials: .anonymous) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case let .success(user):
					self?.completeSignIn(type: .anonymous, user: user, error: nil)
				case let .failure(error):
					self?.completeSignIn(type: .anonymous, user: nil, error: error)
				}
			}
		}
	}

	@IBAction func signIn(_ sender: UIButton) {
		setLoading(true)
		app.login(credentials: .emailPassword(email: username!, password: password!)) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case let .success(user):
					self?.updateKeychain()
					self?.completeSignIn(type: .emailPassword, user: user, error: nil)
				case let .failure(error):
					self?.completeSignIn(type: .emailPassword, user: nil, error: error)
				}
			}
		}
	}
	
	@IBAction func signUp(_ sender: UIButton) {
		setLoading(true)
		app.emailPasswordAuth.registerUser(email: username!, password: password!, completion: { [weak self] error in
			DispatchQueue.main.async {
				self!.setLoading(false)
				guard error == nil else {
					self?.showErrorAlert(message: "Signup failed: \(error!.localizedDescription)")
					return
				}
				
				self?.showAlert(title: "Sign Up succeeded", message: "Check your email inbox for a confirmation message")
			}
		})
	}

	@IBAction func cancelLogin(_ sender: UIBarButtonItem) {
		dismiss(animated: true) {
			// Do something?
		}
	}
	
	@IBAction func signOut() {
		switch authType {
		case .anonymous, .emailPassword:
			break
		default:
			break
		}
		
		authType	= .none
	}
	
	// MARK: - UITextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField === usernameField {
			passwordField.becomeFirstResponder()
		} else if textField === passwordField {
			view.endEditing(true)
		}
		
		return false
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		guard let field = textField as? AKFloatingLabelTextField else { return true }
		
		if field === usernameField, let text = field.text as NSString? {
			let newText		= text.replacingCharacters(in: range, with: string)
			var message		= ""
			var validation: AKFloatingLabelTextField.TextFieldState	= .valid
			
			if !LoginViewController.emailCheck.evaluate(with: newText) {
				validation	= .invalid
				message		= "Invalid email"
			}
			
			signInButton.isEnabled	= validation == .valid
			signUpButton.isEnabled	= validation == .valid
			
			field.updateState(validation, withMessage: message)
			
			return true
		}
		return field.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
	}
}
