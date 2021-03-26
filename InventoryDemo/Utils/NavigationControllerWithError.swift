//
//  NavigationControllerWithError.swift
//
// UINavigationController with error message and obfuscating view when put in background
//
//

import UIKit

class NavigationControllerWithError: UINavigationController {
	var errorMessageView: UIView!
	var errorMessages: [(String, Bool)]!
	var alertLabel: UILabel!
	var alertImage: UIImageView!
	var maskingView: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		errorMessages	= [(String, Bool)]()
		
		setUpMaskingView()
		setUpNotifications()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		if errorMessageView == nil {
			createErrorView()
		} else {
			errorMessageView.frame.size.width	= view.bounds.width
		}
		
		if errorMessageView.isHidden {
			errorMessageView.frame.origin.y	= view.bounds.minY + view.bounds.height
		} else {
			errorMessageView.frame.origin.y	= view.bounds.minY + view.bounds.height - errorMessageView.frame.height
		}
	}
	
	// MARK: - Setup
	
	func setUpNotifications() {
		let nc	= NotificationCenter.default
		
		nc.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
			DispatchQueue.main.async {
				self?.maskingView.alpha		= 0.0
				self?.maskingView.isHidden	= true
				
#if !targetEnvironment(simulator)
				// Jailbreak check
				if FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") { print([String]()[5]) }
#endif
			}
		}
		
		nc.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in
			if let maskView = self?.maskingView {
				self?.view.bringSubviewToFront(maskView)
				maskView.alpha		= 1.0
				maskView.isHidden	= false
			}
		}
	}
	
	func setUpMaskingView() {
		// Posts a blocking view when in background
		maskingView						= UIView(frame: view.bounds)
		maskingView.autoresizingMask	= [.flexibleWidth, .flexibleHeight]
		
		if !UIAccessibility.isReduceTransparencyEnabled {
			let blurEffect	= UIBlurEffect(style: .extraLight)
			let blurView	= UIVisualEffectView(effect: blurEffect)
			
			blurView.frame				= maskingView.bounds
			blurView.autoresizingMask	= [.flexibleWidth, .flexibleHeight]
			
			maskingView.addSubview(blurView)
		} else {
			maskingView.backgroundColor		= .white
		}
		
		view.addSubview(maskingView)
		
		maskingView.alpha		= 0.0
		maskingView.isHidden	= true
	}
	
	func createErrorView() {
		// Do any additional setup after loading the view.
		errorMessageView							= UIView(frame: CGRect(x: 0.0, y: view.bounds.minY + view.bounds.height,
		                							                       width: view.bounds.width, height: 52.0))
		errorMessageView.isHidden					= true
		errorMessageView.autoresizingMask			= [.flexibleWidth, .flexibleTopMargin]
		errorMessageView.backgroundColor			= UIColor(named: "messageColor") ?? UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)
		errorMessageView.isUserInteractionEnabled	= true
		
		alertImage					= UIImageView(frame: CGRect(x: 10.0, y: 18.0, width: 16.0, height: 16.0))
		
		alertImage.image			= UIImage(named: "Alert")
		alertImage.tintColor		= .white
		alertImage.autoresizingMask	= [.flexibleTopMargin, .flexibleBottomMargin, .flexibleRightMargin]
		alertImage.isHidden			= true
		
		errorMessageView.addSubview(alertImage)
		
		alertLabel					= UILabel(frame: CGRect(x: 32.0, y: 10.0,
		          					                        width: view.bounds.width - 42.0, height: 32.0))
		
		alertLabel.autoresizingMask		= [.flexibleWidth, .flexibleHeight]
		alertLabel.numberOfLines		= 2
		alertLabel.font					= UIFont.preferredFont(forTextStyle: .caption1)
		alertLabel.textColor			= .white
		alertLabel.accessibilityLabel	= "Error Message"
		
		errorMessageView.addSubview(alertLabel)
		
		errorMessageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideErrorMessage)))
		
		view.addSubview(errorMessageView)
	}
	
	// MARK: - Actions
	
	@objc func postErrorMessage(message: String, isError: Bool = false) {
		errorMessages.append((message, isError))
		
		showErrorMessage()
	}
	
	@objc func showErrorMessage() {
		guard errorMessages != nil, errorMessageView != nil else {
			// Not ready yet, re-post for later
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
				self?.showErrorMessage()
			}
			return
		}
		guard !errorMessages.isEmpty, errorMessageView.isHidden else { return }
		
		let (message, isError)			= errorMessages[0]
		
		alertLabel.text					= message
		alertLabel.accessibilityValue	= message

		if isError {
			errorMessageView.backgroundColor	= UIColor(named: "errorColor") ?? UIColor(red: 0.75, green: 0.25, blue: 0.25, alpha: 1.0)
			alertImage.isHidden					= false
		} else {
			errorMessageView.backgroundColor	= UIColor(named: "messageColor") ?? UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0)
			alertImage.isHidden					= true
		}
		
		view.bringSubviewToFront(errorMessageView)
		errorMessageView.isHidden	= false
		
		UIView.animate(withDuration: 0.3, animations: {
			let bounds 	= self.view.bounds
			
			self.errorMessageView.frame.origin.y	= bounds.minY + bounds.height - self.errorMessageView.frame.height
		}) { _ in
			DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
				self.hideErrorMessage()
			}
		}
	}
	
	@IBAction func hideErrorMessage() {
		guard !errorMessageView.isHidden else { return }
		
		UIView.animate(withDuration: 0.3, animations: {
			let bounds 	= self.view.bounds
			
			self.errorMessageView.frame.origin.y	= bounds.minY + bounds.height
		}) { _ in
			self.errorMessageView.isHidden	= true
			
			if !self.errorMessages.isEmpty { self.errorMessages.remove(at: 0) }
			if !self.errorMessages.isEmpty { self.showErrorMessage() }
		}
	}
}
