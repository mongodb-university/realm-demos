//
//  AKFloatingLabelTextField.swift
//  AKFloatingLabel
//
//  Created by Diogo Autilio on 07/03/2017.
//  Copyright (c) 2017 Diogo Autilio. All rights reserved.
//

import UIKit

@IBDesignable
open class AKFloatingLabelTextField: UITextField, UITextFieldDelegate {
	// MARK: - Public Properties
	
	public enum TextFieldState: Int {
		case idle = 0
		case valid
		case invalid
	}
	
	/**
	 * Read-only access to the floating label.
	 */
	public var floatingLabel = UILabel()
	
	/**
	 * Read-only access to the floating error label.
	 */
	public var floatingLabelError = UILabel()
	
	/**
	 * Font to be applied to the floating label.
	 * Defaults to the first applicable of the following:
	 * - the custom specified attributed placeholder font at 70% of its size
	 * - the custom specified textField font at 70% of its size
	 */
	public var floatingLabelFont: UIFont? {
		didSet {
			floatingLabel.font = (floatingLabelFont != nil) ? floatingLabelFont : defaultFloatingLabelFont()
			isFloatingLabelFontDefault = floatingLabelFont == nil
			invalidateIntrinsicContentSize()
		}
	}
	
	/**
	 * Duration of the animation when showing the floating label.
	 * Defaults to 0.3 seconds.
	 */
	public var floatingLabelShowAnimationDuration: TimeInterval = 0.3
	
	/**
	 * Duration of the animation when hiding the floating label.
	 * Defaults to 0.3 seconds.
	 */
	public var floatingLabelHideAnimationDuration: TimeInterval = 0.3
	
	/**
	 * Current textfield validation state.
	 * Defaults to .idle
	 */
	public var currentValidationState: TextFieldState = .idle
	
	// MARK: - Public IBInspectable Properties
	
	/**
	 * Ratio by which to modify the font size of the floating label.
	 * Defaults to 70
	 */
	@IBInspectable public var floatingLabelReductionRatio: CGFloat = 70 {
		didSet {
			floatingLabelFont = defaultFloatingLabelFont()
			floatingLabel.font = floatingLabelFont
		}
	}
	
	/**
	 * Text color to be applied to the floating label.
	 * Defaults to `UIColor.gray`.
	 */
	@IBInspectable public var floatingLabelTextColor: UIColor = .gray
	
	/**
	 * Text color to be applied to the invalid label.
	 * Defaults to `UIColor.red`.
	 */
	@IBInspectable public var invalidTextFieldColor: UIColor = .red
	
	/**
	 * Text color to be applied to the invalid label.
	 * Defaults to `UIColor.gray`.
	 */
	@IBInspectable public var validTextFieldColor: UIColor = .gray
	
	/**
	 * Indicates whether the clearButton position is adjusted to align with the text
	 * Defaults to true.
	 */
	@IBInspectable public var adjustsClearButtonRect: Bool = true
	
	/**
	 * Text color to be applied to the floating label while the field is a first responder.
	 * Tint color is used by default if an `floatingLabelActiveTextColor` is not provided.
	 */
	@IBInspectable public var floatingLabelActiveTextColor: UIColor?
	
	/**
	 * Padding to be applied to the y coordinate of the placeholder.
	 * Defaults to zero.
	 */
	@IBInspectable public var placeholderYPadding: CGFloat = 0
	
	/**
	 * Padding to be applied to the x coordinate of the floating label upon presentation.
	 * Defaults to zero
	 */
	@IBInspectable public var floatingLabelXPadding: CGFloat = 0
	
	/**
	 * Padding to be applied to the y coordinate of the floating label upon presentation.
	 * Defaults to zero.
	 */
	@IBInspectable public var floatingLabelYPadding: CGFloat = 0
	
	/**
	 * Indicates whether or not to drop the baseline when entering text.
	   Setting to true (not the default) means the standard greyed-out placeholder will be aligned with the entered text
	 * Defaults to false (standard placeholder will be above whatever text is entered)
	 */
	@IBInspectable public var keepBaseline: Bool = false
	
	/**
	 * Should add bottom border.
	 * Defaults to true
	 */
	@IBInspectable public var hasBottomBorder: Bool = true
	
	/**
	 * Change the tint color of the clear button
	 * Defaults to nil
	 */
	@IBInspectable public var clearButtonColor: UIColor?
	
	// MARK: - Private Properties
	
	private var isFloatingLabelFontDefault: Bool = true
	
	private var bottomBorder = CALayer()
	
	// MARK: -
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit() {
		floatingLabel.alpha = 0.0
		addSubview(floatingLabel)
		
		// some basic default fonts/colors
		floatingLabelFont = defaultFloatingLabelFont()
		floatingLabel.font = floatingLabelFont
		floatingLabel.textColor = floatingLabelTextColor
		setFloatingLabelText(placeholder)
		
		floatingLabelError.text = ""
		floatingLabelError.font = defaultFloatingLabelFont()
		floatingLabelError.textColor = invalidTextFieldColor
		floatingLabelError.textAlignment = .left
		floatingLabelError.alpha = 1.0
		addSubview(floatingLabelError)
		
		layer.addSublayer(bottomBorder)
		
		delegate = self
	}
	
	// MARK: -
	
	func defaultFloatingLabelFont() -> UIFont? {
		var textFieldFont: UIFont?
		
		if textFieldFont == nil, attributedPlaceholder != nil, let placeholder = attributedPlaceholder, placeholder.length > 0 {
			textFieldFont = attributedPlaceholder?.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
		}
		if textFieldFont == nil, attributedText != nil, let placeholder = attributedText, placeholder.length > 0 {
			textFieldFont = attributedText?.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
		}
		if textFieldFont == nil {
			textFieldFont = font
		}
		
		guard let safeTextFieldFont = textFieldFont else {
			return nil
		}
		
		let fontSize = roundf(Float(safeTextFieldFont.pointSize * (floatingLabelReductionRatio / 100)))
		return UIFont(name: safeTextFieldFont.fontName, size: CGFloat(fontSize))
	}
	
	func updateDefaultFloatingLabelFont() {
		let derivedFont = defaultFloatingLabelFont()
		
		if isFloatingLabelFontDefault {
			floatingLabelFont = derivedFont
		} else {
			// dont apply to the label, just store for future use where floatingLabelFont may be reset to nil
			floatingLabelFont = derivedFont
		}
	}
	
	func labelActiveColor() -> UIColor {
		if let floatingLabelActiveTextColor = floatingLabelActiveTextColor {
			return floatingLabelActiveTextColor
		} else if responds(to: #selector(getter: tintColor)) {
			return self.tintColor
		}
		return .blue
	}
	
	// MARK: - Floating label visibility
	
	func showFloatingLabel(_ animated: Bool) {
		let showBlock: (() -> Void) = { () -> Void in
			self.floatingLabel.alpha = 1.0
			self.floatingLabel.frame = CGRect(x: self.floatingLabel.frame.origin.x,
			                                  y: self.floatingLabelYPadding,
			                                  width: self.floatingLabel.frame.size.width,
			                                  height: self.floatingLabel.frame.size.height)
		}
		if animated {
			UIView.animate(withDuration: floatingLabelShowAnimationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseOut], animations: showBlock) { _ in }
		} else {
			showBlock()
		}
	}
	
	func hideFloatingLabel(_ animated: Bool) {
		let hideBlock: (() -> Void) = { () -> Void in
			self.floatingLabel.alpha = 0.0
			self.floatingLabel.frame = CGRect(x: self.floatingLabel.frame.origin.x,
			                                  y: self.floatingLabel.font.lineHeight + self.placeholderYPadding,
			                                  width: self.floatingLabel.frame.size.width,
			                                  height: self.floatingLabel.frame.size.height)
		}
		if animated {
			UIView.animate(withDuration: floatingLabelHideAnimationDuration, delay: 0.0, options: [.beginFromCurrentState, .curveEaseIn], animations: hideBlock) { _ in }
		} else {
			hideBlock()
		}
	}
	
	// MARK: -
	
	func setLabelOriginForTextAlignment() {
		let textRect = self.textRect(forBounds: bounds)
		var originX = textRect.origin.x
		
		if textAlignment == .center {
			originX = textRect.origin.x + (textRect.size.width / 2) - (floatingLabel.frame.size.width / 2)
		} else if textAlignment == .right {
			originX = textRect.origin.x + textRect.size.width - floatingLabel.frame.size.width
		}
		floatingLabel.frame = CGRect(x: originX + floatingLabelXPadding,
		                             y: floatingLabel.frame.origin.y,
		                             width: floatingLabel.frame.size.width,
		                             height: floatingLabel.frame.size.height)
	}
	
	func setLabelErrorOriginForTextAlignment() {
		floatingLabelError.frame = CGRect(x: 0, y: frame.size.height + 2.0, width: 300, height: 20.0)
	}
	
	func setBorder() {
		if hasBottomBorder {
			bottomBorder.borderColor = validTextFieldColor.cgColor
			bottomBorder.frame = CGRect(x: 0, y: frame.size.height, width: frame.size.width, height: 1)
			bottomBorder.borderWidth = 1.0
			layer.masksToBounds = false
		}
	}
	
	func setFloatingLabelText(_ text: String?) {
		floatingLabel.text = text
		setNeedsLayout()
	}
	
	// MARK: - UITextField
	
	override open var font: UIFont? {
		didSet {
			updateDefaultFloatingLabelFont()
		}
	}
	
	override open var attributedText: NSAttributedString? {
		didSet {
			updateDefaultFloatingLabelFont()
		}
	}
	
	override open var intrinsicContentSize: CGSize {
		let textFieldIntrinsicContentSize = super.intrinsicContentSize
		floatingLabel.sizeToFit()
		return CGSize(width: textFieldIntrinsicContentSize.width, height: textFieldIntrinsicContentSize.height + floatingLabelYPadding + floatingLabel.bounds.size.height)
	}
	
	func setCorrectPlaceholder(_ placeholder: String?) {
		if let placeholderColor = placeholderColor, let placeholder = placeholder {
			let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: placeholderColor])
			super.attributedPlaceholder = attributedPlaceholder
		} else {
			super.placeholder = placeholder
		}
	}
	
	override open var placeholder: String? {
		didSet {
			setCorrectPlaceholder(placeholder)
			setFloatingLabelText(placeholder)
		}
	}
	
	override open var attributedPlaceholder: NSAttributedString? {
		didSet {
			setFloatingLabelText(attributedPlaceholder?.string)
			updateDefaultFloatingLabelFont()
		}
	}
	
	/**
	 * Color of the placeholder
	 */
	@IBInspectable public var placeholderColor: UIColor? {
		didSet {
			self.setCorrectPlaceholder(self.placeholder)
		}
	}
	
	// MARK: - Private Methods
	
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.textRect(forBounds: bounds)
		
		let textIsEmpty = (text?.isEmpty ?? true)
		
		if !textIsEmpty || keepBaseline {
			rect = insetRect(forBounds: rect)
		}
		return rect.integral
	}
	
	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.editingRect(forBounds: bounds)
		
		let textIsEmpty = (text?.isEmpty ?? true)
		
		if !textIsEmpty || keepBaseline {
			rect = insetRect(forBounds: rect)
		}
		return rect.integral
	}
	
	func insetRect(forBounds rect: CGRect) -> CGRect {
		var topInset = ceilf(Float(floatingLabel.bounds.size.height + placeholderYPadding))
		topInset = min(topInset, maxTopInset())
		return CGRect(x: rect.origin.x, y: rect.origin.y + CGFloat(topInset / 2.0), width: rect.size.width - 20, height: rect.size.height)
	}
	
	override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.clearButtonRect(forBounds: bounds)
		
		let floatingLabelIsEmpty = (floatingLabel.text?.isEmpty ?? true)
		
		if adjustsClearButtonRect, !floatingLabelIsEmpty {
			let textIsEmpty = (text?.isEmpty ?? true)
			
			if !textIsEmpty || keepBaseline {
				var topInset = ceilf(Float(floatingLabel.font.lineHeight + placeholderYPadding))
				topInset = min(topInset, maxTopInset())
				rect = CGRect(x: rect.origin.x, y: rect.origin.y + CGFloat(topInset / 2.0), width: rect.size.width, height: rect.size.height)
			}
		}
		return rect.integral
	}
	
	override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.leftViewRect(forBounds: bounds)
		var topInset = ceilf(Float(floatingLabel.font.lineHeight + placeholderYPadding))
		topInset = min(topInset, maxTopInset())
		rect = rect.offsetBy(dx: 0, dy: CGFloat(topInset / 2.0))
		return rect
	}
	
	override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.rightViewRect(forBounds: bounds)
		var topInset = ceilf(Float(floatingLabel.font.lineHeight + placeholderYPadding))
		topInset = min(topInset, maxTopInset())
		rect = rect.offsetBy(dx: 0, dy: CGFloat(topInset / 2.0))
		return rect
	}
	
	private func maxTopInset() -> Float {
		guard let font = font else {
			return 0.0
		}
		return max(0.0, floorf(Float(bounds.size.height - font.lineHeight - 4.0)))
	}
	
	private func tintClearImageIfNeeded() {
		if let clearButtonColor = self.clearButtonColor {
			for view in subviews {
				if let button = view as? UIButton {
					button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
					button.tintColor = clearButtonColor
				}
			}
		}
	}
	
	override open var textAlignment: NSTextAlignment {
		didSet {
			setNeedsLayout()
		}
	}
	
	/**
	 * Force floating label to be always visible
	 * Defaults to false
	 */
	@IBInspectable public var alwaysShowFloatingLabel: Bool = false {
		didSet {
			setNeedsLayout()
		}
	}
	
	override open func layoutSubviews() {
		super.layoutSubviews()
		setLabelOriginForTextAlignment()
		setLabelErrorOriginForTextAlignment()
		setBorder()
		
		if let floatingLabelBounds = floatingLabel.superview?.bounds {
			let floatingLabelSize = floatingLabel.sizeThatFits(floatingLabelBounds.size)
			floatingLabel.frame = CGRect(x: floatingLabel.frame.origin.x, y: floatingLabel.frame.origin.y,
			                             width: floatingLabelSize.width, height: floatingLabelSize.height)
		}
		
		let firstResponder = isFirstResponder
		let textIsEmpty = (text?.isEmpty ?? true)
		
		floatingLabel.textColor = firstResponder && !textIsEmpty ? labelActiveColor() : floatingLabelTextColor
		
//		if !firstResponder, !alwaysShowFloatingLabel {
		if textIsEmpty, !alwaysShowFloatingLabel {
			hideFloatingLabel(firstResponder)
		} else {
			showFloatingLabel(firstResponder)
		}
		
		tintClearImageIfNeeded()
	}
	
	// MARK: - <UITextFieldDelegate>
	
	public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if let field = (textField as? AKFloatingLabelTextField) {
			field.updateState(.valid, withMessage: "")
		}
		return true
	}
	
	// MARK: - Public Methods
	
	/**
	 *  Sets the placeholder and the floating title
	 *
	 *  @param placeholder The string that to be shown in the text field when no other text is present.
	 *  @param floatingTitle The string to be shown above the text field once it has been populated with text by the user.
	 */
	public func setPlaceholder(_ placeholder: String, floatingTitle: String) {
		setCorrectPlaceholder(placeholder)
		setFloatingLabelText(floatingTitle)
	}
	
	/**
	 *  Sets the attributed placeholder and the floating title
	 *
	 *  @param attributedPlaceholder The string that to be shown in the text field when no other text is present.
	 *  @param floatingTitle The string to be shown above the text field once it has been populated with text by the user.
	 */
	public func setAttributedPlaceholder(_ attributedPlaceholder: NSAttributedString, floatingTitle: String) {
		super.attributedPlaceholder = attributedPlaceholder
		setFloatingLabelText(floatingTitle)
	}
	
	public func updateState(_ validationState: TextFieldState, withMessage message: String) {
		var lineColor: UIColor?
		currentValidationState = validationState
		
		switch validationState {
		case .valid:
			lineColor = validTextFieldColor
			floatingLabelError.text = message
		case .invalid:
			lineColor = invalidTextFieldColor
			if !message.isEmpty {
				floatingLabelError.text = message
			}
		default:
			break
		}
		
		if hasBottomBorder {
			bottomBorder.borderColor = lineColor?.cgColor
			layer.masksToBounds = false
		}
	}
	
	public func hideBottomBar() {
		bottomBorder.isHidden = true
	}
}
