//
//  FA_TokenInputView.swift
//  Pods
//
//  Created by Pierre LAURAC on 29/06/2015.
//
//

import Foundation

@objc public protocol FA_TokenInputViewDelegate: class {
  
  /**
   *  Called when the text field begins editing
   */
  optional func tokenInputViewDidEnditing(view: FA_TokenInputView)
  
  /**
   *  Called when the text field ends editing
   */
  optional func tokenInputViewDidBeginEditing(view: FA_TokenInputView)
  
  /**
   * Called when the text field text has changed. You should update your autocompleting UI based on the text supplied.
   */
  optional func tokenInputViewDidChangeText(view: FA_TokenInputView, text theNewText: String)
  
  /**
   * Called when a token has been added. You should use this opportunity to update your local list of selected items.
   */
  optional func tokenInputViewDidAddToken(view: FA_TokenInputView, token theNewToken: FA_Token)
  
  /**
   * Called when a token has been removed. You should use this opportunity to update your local list of selected items.
   */
  optional func tokenInputViewDidRemoveToken(view: FA_TokenInputView, token removedToken: FA_Token)
  
  /**
   * Called when the user attempts to press the Return key with text partially typed.
   * @return A CLToken for a match (typically the first item in the matching results),
   * or nil if the text shouldn't be accepted.
   */
  optional func tokenInputViewTokenForText(view: FA_TokenInputView, text searchToken: String) -> FA_Token?
  
  /**
   * Called when the view has updated its own height. If you are
   * not using Autolayout, you should use this method to update the
   * frames to make sure the token view still fits.
   */
  optional func tokenInputViewDidChangeHeight(view: FA_TokenInputView,  height newHeight:CGFloat)
  
  /**
   * Called when the view has received a double tap gesture. If you want to display a menu above
   * the `FA_TokenView` return true.
   * In order to display the items, you should also implement `tokenInputViewMenuItems`
   *
   * @return true if you want to display a UIMenuController element
   */
  optional func tokenInputViewShouldDisplayMenuItems(view: FA_TokenInputView) -> Bool
  
  /**
   * Called if the `tokenInputViewShouldDisplayMenuItems` returned true.
   * Return the UIMenuItem you want to display above or below the `FA_Token`
   *
   * @return the array of `UIMenuItem`
   */
  optional func tokenInputViewMenuItems(view: FA_TokenInputView, token: FA_Token) -> [UIMenuItem]
}

public enum FA_TokenInputViewMode {
  case View
  case Edit
}

public class FA_TokenInputView: UIView {
  
  @IBOutlet weak public var delegate: FA_TokenInputViewDelegate?
  var _fieldView: UIView?
  var _accessoryView: UIView?
  
  @IBInspectable var _fieldName: String?
  @IBInspectable var _placeholderText: String?
  @IBInspectable var _keyboardType: UIKeyboardType = .Default
  @IBInspectable var _autocapitalizationType: UITextAutocapitalizationType = .None
  @IBInspectable var _autocorrectionType: UITextAutocorrectionType = .No
  @IBInspectable var _drawBottomBorder: Bool = false
  
  public var allTokens: [FA_Token] {
    return self.tokens.map { $0 }
  }
  
  var text: String {
    return self.textField.text!
  }
  
  var editing: Bool {
    return self.textField.editing
  }
  
  var tokenizeOnEndEditing = true
  
  public var font: UIFont! {
    didSet {
      self.textField?.font = self.font
      for view in tokenViews {
        view.font = self.font
      }
    }
  }
  
  public var fieldNameFont: UIFont! {
    didSet {
      self.fieldLabel?.font = self.fieldNameFont
    }
  }
  
  public var fieldNameColor: UIColor! {
    didSet {
      self.fieldLabel?.textColor = self.fieldNameColor
    }
  }
  
  private var tokens: [FA_Token] = []
  private var tokenViews: [FA_TokenView] = []
  private var textField: FA_BackspaceDetectingTextField!
  private var fieldLabel: UILabel!
  private var intrinsicContentHeight: CGFloat!
  private var displayMode: FA_TokenInputViewMode!
  private var heightZeroConstraint: NSLayoutConstraint!
  
  private var textColor: UIColor!
  private var selectedTextColor: UIColor!
  private var selectedBackgroundColor: UIColor!
  private var separatorColor: UIColor!
  
  public var HSPACE: CGFloat = 0.0
  public var TEXT_FIELD_HSPACE: CGFloat = 4.0
  
  /// The space betwen each rows
  public var VERTICAL_SPACE_BETWEEN_ROWS: CGFloat = 4.0
  
  /// The minimum space the textfield should be. If the space cannot be allocated, then a new line will be created
  public var MINIMUM_TEXTFIELD_WIDTH: CGFloat = 10.0
  
  public var PADDING_TOP: CGFloat = 10.0
  public var PADDING_BOTTOM: CGFloat = 10.0
  public var PADDING_LEFT: CGFloat = 8.0
  public var PADDING_RIGHT: CGFloat = 16.0
  public var STANDARD_ROW_HEIGHT: CGFloat = 25.0
  public var FIELD_MARGIN_X: CGFloat = 4.0
  
  /// Minimum height size for the view if empty
  public var MINIMUM_VIEW_HEIGHT: CGFloat = 45.0
  
  public convenience init() {
    self.init(mode: .Edit)
  }
  
  public init(mode: FA_TokenInputViewMode) {
    super.init(frame: CGRectZero)
    self.commonInit(mode)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  func commonInit(mode: FA_TokenInputViewMode = .Edit) {
    
    self.font = UIFont.systemFontOfSize(17.0)
    self.textField = FA_BackspaceDetectingTextField(frame: self.bounds)
    self.textField.backgroundColor = UIColor.clearColor()
    self.textField.keyboardType = self.keyboardType;
    self.textField.autocorrectionType = self.autocorrectionType;
    self.textField.autocapitalizationType = self.autocapitalizationType;
    self.textField.delegate = self
    self.textField.addTarget(self, action: #selector(FA_TokenInputView.onTextFieldDidChange(_:)), forControlEvents: .EditingChanged)
    self.textField.addTarget(self, action: #selector(FA_TokenInputView.onTextFieldDidEndEditing(_:)), forControlEvents: .EditingDidEnd)
    self.addSubview(self.textField)
    
    self.fieldLabel = UILabel(frame: CGRectZero)
    self.fieldLabel.textColor = UIColor.lightGrayColor()
    self.addSubview(self.fieldLabel)
    self.fieldLabel.hidden = true
    
    self.backgroundColor = UIColor.clearColor()
    self.intrinsicContentHeight = self.STANDARD_ROW_HEIGHT
    self.repositionViews()
    
    self.clipsToBounds = true
    self.displayMode = mode
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FA_TokenInputView.viewWasTapped)))
    self.heightZeroConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.0)
    
    self.setDefaultColors()
  }
  
  override public func intrinsicContentSize() -> CGSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, max(self.MINIMUM_VIEW_HEIGHT, self.intrinsicContentHeight))
  }
  
  public func setColors(textColor: UIColor, selectedTextColor: UIColor, selectedBackgroundColor: UIColor) {
    
    self.textColor = textColor
    self.selectedTextColor = selectedTextColor
    self.selectedBackgroundColor = selectedBackgroundColor
    
    self.tokenViews.forEach { (tokenView) in
      tokenView.setColors(textColor, selectedTextColor: selectedTextColor, selectedBackgroundColor: selectedBackgroundColor)
    }
  }
  
  public func addToken(token theToken: FA_Token) {
    if self.tokens.contains(theToken) {
      return
    }
    
    self.tokens.append(theToken)
    let tokenView = FA_TokenView(token: theToken, displayMode: self.displayMode)
    tokenView.font = self.font
    tokenView.delegate = self;
    tokenView.setColors(self.textColor, selectedTextColor: self.selectedTextColor, selectedBackgroundColor: self.selectedBackgroundColor)
    let intrinsicSize = tokenView.intrinsicContentSize()
    tokenView.frame = CGRectMake(0, 0, intrinsicSize.width, intrinsicSize.height);
    self.tokenViews.append(tokenView)
    self.addSubview(tokenView)
    self.textField.text = ""
    self.delegate?.tokenInputViewDidAddToken?(self, token: theToken)
    
    // Clearing text programmatically doesn't call this automatically
    self.onTextFieldDidChange(self.textField)
    
    self.updatePlaceholderTextVisibility()
    self.repositionViews()
  }
  
  public func setHeightToZero() {
    self.addConstraint(self.heightZeroConstraint)
  }
  
  public func setHeightToAuto() {
    self.removeConstraint(self.heightZeroConstraint)
  }
  
  public func removeAllTokens() {
    let tokens = self.tokens
    self.tokens = []
    self.tokenViews = []
    tokens.forEach {
      self.delegate?.tokenInputViewDidRemoveToken?(self, token: $0)
    }
    self.repositionViews()
  }
  
  public func removeToken(token theToken: FA_Token) {
    if let index = self.tokens.indexOf({ (token) -> Bool in return token == theToken }) {
      self.removeTokenAtIndex(index)
    }
  }
  
  public func setInputAccessoryView(view: UIView) {
    self.textField.inputAccessoryView = view
  }
  
  public func forceTokenizeCurrentText() {
    self.tokenizeTextFieldText()
  }
  
  private func removeTokenAtIndex(index: Int) {
    let tokenView = self.tokenViews[index]
    tokenView.removeFromSuperview()
    self.tokenViews.removeAtIndex(index)
    
    let removedToken = self.tokens[index]
    self.tokens.removeAtIndex(index)
    self.delegate?.tokenInputViewDidRemoveToken?(self, token: removedToken)
    
    self.updatePlaceholderTextVisibility()
    self.repositionViews()
  }
  
  private func tokenizeTextFieldText() -> FA_Token? {
    
    let text = self.textField.text;
    if !text!.isEmpty {
      if let token = self.delegate?.tokenInputViewTokenForText?(self, text: text!) {
        self.addToken(token: token)
        self.onTextFieldDidChange(self.textField)
        return token
      }
    }
    
    return nil
  }
  
  private func setDefaultColors() {
    if let tint = self.tintColor {
      self.textColor = tint
      self.selectedBackgroundColor = tint
      self.selectedTextColor = UIColor.whiteColor()
      return
    }
    
    self.textColor = UIColor.blackColor()
    self.selectedTextColor = UIColor.whiteColor()
    self.selectedBackgroundColor = UIColor.blackColor()
  }
  
  private func textFieldDisplayOffset() -> CGFloat {
    // Essentially the textfield's y with PADDING_TOP
    return CGRectGetMinY(self.textField.frame) - self.PADDING_TOP
  }
  
  private func repositionViews() {
    let bounds = self.bounds
    
    if bounds.height == 0 {
      self.repositionViewZeroHeight()
      return
    }
    
    let rightBoundary = CGRectGetWidth(bounds) - self.PADDING_RIGHT
    var firstLineRightBoundary = rightBoundary
    
    var curX = self.PADDING_LEFT
    var curY = self.PADDING_TOP
    var isOnFirstLine = true
    var yPositionForLastToken: CGFloat = 0.0
    
    // Position field view (if set)
    if let fieldView = self.fieldView {
      fieldView.sizeToFit()
      var fieldViewRect = fieldView.frame
      fieldViewRect.origin.x = curX + self.FIELD_MARGIN_X
      fieldViewRect.origin.y = curY + ((self.STANDARD_ROW_HEIGHT - CGRectGetHeight(fieldViewRect))/2.0)
      fieldView.frame = fieldViewRect
      
      curX = CGRectGetMaxX(fieldViewRect) + self.FIELD_MARGIN_X
    }
    
    // Position field label (if field name is set)
    if !self.fieldLabel.hidden {
      self.fieldLabel.sizeToFit()
      var fieldLabelRect = self.fieldLabel.frame
      fieldLabelRect.origin.x = curX + self.FIELD_MARGIN_X
      fieldLabelRect.origin.y = curY + ((self.STANDARD_ROW_HEIGHT-CGRectGetHeight(fieldLabelRect))/2.0)
      self.fieldLabel.frame = fieldLabelRect
      
      curX = CGRectGetMaxX(fieldLabelRect) + self.FIELD_MARGIN_X
    }
    
    // Position accessory view (if set)
    if let accessoryView = self.accessoryView {
      accessoryView.sizeToFit()
      var accessoryRect = accessoryView.frame
      accessoryRect.origin.x = CGRectGetWidth(bounds) - self.PADDING_RIGHT - CGRectGetWidth(accessoryRect)
      accessoryRect.origin.y = curY
      accessoryView.frame = accessoryRect
      
      firstLineRightBoundary = CGRectGetMinX(accessoryRect) - self.HSPACE
    }
    
    // Position token views
    var tokenRect = CGRectNull
    for view in self.tokenViews {
      view.sizeToFit()
      tokenRect = view.frame
      
      let tokenBoundary = isOnFirstLine ? firstLineRightBoundary : rightBoundary
      if (curX + CGRectGetWidth(tokenRect) > tokenBoundary) {
        // Need a new line
        curX = self.PADDING_LEFT
        curY += self.STANDARD_ROW_HEIGHT+self.VERTICAL_SPACE_BETWEEN_ROWS
        isOnFirstLine = false
      }
      
      tokenRect.origin.x = curX
      // Center our tokenView vertially within STANDARD_ROW_HEIGHT
      tokenRect.origin.y = curY + ((self.STANDARD_ROW_HEIGHT-CGRectGetHeight(tokenRect))/2.0)
      if tokenRect.width > self.getMaxLineWidth() {
        tokenRect.size.width = self.getMaxLineWidth()
      }
      view.frame = tokenRect
      
      curX = CGRectGetMaxX(tokenRect) + self.HSPACE
      yPositionForLastToken = tokenRect.origin.y
      view.setSeparatorVisibility(view != self.tokenViews.last || self.editing)
    }
    
    
    
    // Always indent textfield by a little bit
    curX += self.TEXT_FIELD_HSPACE
    let textBoundary = isOnFirstLine ? firstLineRightBoundary : rightBoundary
    var availableWidthForTextField = textBoundary - curX
    if (availableWidthForTextField < self.MINIMUM_TEXTFIELD_WIDTH) {
      isOnFirstLine = false
      curX = self.PADDING_LEFT + self.TEXT_FIELD_HSPACE
      curY += self.STANDARD_ROW_HEIGHT+self.VERTICAL_SPACE_BETWEEN_ROWS
      // Adjust the width
      availableWidthForTextField = rightBoundary - curX
    }
    
    if (!self.editing && curY > yPositionForLastToken && !self.tokens.isEmpty) {
      // check if there is another token on the line and if not we should remove the line height
      curY -= self.STANDARD_ROW_HEIGHT+self.VERTICAL_SPACE_BETWEEN_ROWS
    }
    
    if self.editing {
      self.textField.frame = CGRectMake(curX, curY, availableWidthForTextField, self.STANDARD_ROW_HEIGHT)
    } else {
      self.textField.frame = CGRectZero
    }
    
    if self.displayMode == .View {
      self.textField.frame = CGRectZero
    }
    
    let oldContentHeight = self.intrinsicContentHeight
    self.intrinsicContentHeight = self.getIntrinsincContentHeightAfterReposition()
    self.invalidateIntrinsicContentSize()
    
    if (oldContentHeight != self.intrinsicContentHeight) {
      self.delegate?.tokenInputViewDidChangeHeight?(self, height: self.intrinsicContentSize().height)
    }
    self.setNeedsDisplay()
    
  }
  
  private func getMaxLineWidth() -> CGFloat {
    return self.frame.width - self.PADDING_RIGHT - self.PADDING_LEFT
  }
  
  private func getIntrinsincContentHeightAfterReposition() -> CGFloat {
    if self.editing {
      return CGRectGetMaxY(self.textField.frame)+self.PADDING_BOTTOM
    }
    
    guard let view = self.tokenViews.last else {
      return 0
    }
    
    return CGRectGetMaxY(view.frame)+self.PADDING_BOTTOM
  }
  
  private func repositionViewZeroHeight() {
    if let fieldView = self.fieldView {
      let frame = fieldView.frame
      fieldView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 0)
    }
    if let accessoryView = self.accessoryView {
      let frame = accessoryView.frame
      accessoryView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 0)
    }
    let flFrame = fieldLabel.frame
    fieldLabel.frame = CGRectMake(flFrame.origin.x, flFrame.origin.y, flFrame.width, 0)
    
    let tfFrame = textField.frame
    textField.frame = CGRectMake(tfFrame.origin.x, tfFrame.origin.y, tfFrame.width, 0)
    
    for view in self.tokenViews {
      let frame = view.frame
      view.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.width, 0)
    }
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    self.repositionViews()
  }
  
  private func updatePlaceholderTextVisibility() {
    if self.tokens.isEmpty {
      self.textField.placeholder = self.placeholderText
    } else {
      self.textField.placeholder = nil
    }
  }
  
  func onTextFieldDidChange(textfield: UITextField) {
    self.delegate?.tokenInputViewDidChangeText?(self, text: textfield.text!)
  }
  
  func onTextFieldDidEndEditing(textfield: UITextField) {
    self.repositionViews()
  }
  
  func viewWasTapped() {
    self.unselectAllTokenViewsAnimated(true)
    if self.displayMode == .View {
      return
    }
    self.beginEditing()
  }
}

// MARK: - Token Selection
extension FA_TokenInputView {
  func selectTokenView(tokenView theView: FA_TokenView, animated: Bool) {
    theView.setSelected(selected: true, animated: animated)
    for view in self.tokenViews {
      if view != theView {
        view.setSelected(selected: false, animated: animated)
      }
    }
  }
  
  func unselectAllTokenViewsAnimated(animated: Bool) {
    for view in self.tokenViews {
      view.setSelected(selected: false, animated: animated)
    }
  }
}

// MARK: - Editing
extension FA_TokenInputView {
  
  public func beginEditing() {
    
    if self.displayMode == .View {
      return
    }
    self.textField.becomeFirstResponder()
    self.unselectAllTokenViewsAnimated(false)
    self.repositionViews()
  }
  
  public func endEditing() {
    self.resignFirstResponder()
    self.repositionViews()
  }
}

// MARK: - UItextField delegate method
extension FA_TokenInputView: UITextFieldDelegate  {
  
  public func textFieldDidBeginEditing(textField: UITextField) {
    self.accessoryView?.hidden = false
    self.delegate?.tokenInputViewDidBeginEditing?(self)
    self.unselectAllTokenViewsAnimated(true)
  }
  
  public func textFieldDidEndEditing(textField: UITextField) {
    self.accessoryView?.hidden = true
    self.delegate?.tokenInputViewDidEnditing?(self)
    if (self.tokenizeOnEndEditing) {
      self.tokenizeTextFieldText()
    }
  }
  
  public func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.tokenizeTextFieldText()
    return false
  }
  
}

// MARK: - TextField customazation
extension FA_TokenInputView {
  var keyboardType: UIKeyboardType {
    get { return self._keyboardType }
    set {
      self._keyboardType = newValue
      self.textField.keyboardType = _keyboardType
    }
  }
  
  var autocapitalizationType: UITextAutocapitalizationType {
    get { return self._autocapitalizationType }
    set {
      self._autocapitalizationType = newValue
      self.textField.autocapitalizationType = _autocapitalizationType
    }
  }
  
  var autocorrectionType: UITextAutocorrectionType {
    get { return self._autocorrectionType }
    set {
      self._autocorrectionType = newValue
      self.textField.autocorrectionType = _autocorrectionType
    }
  }
}

// MARK: - Optional views
extension FA_TokenInputView {
  
  public var fieldName: String? {
    get { return self._fieldName }
    set {
      if _fieldName == newValue {
        return
      }
      let previous = _fieldName
      
      let showField = !(newValue?.isEmpty ?? true)
      self._fieldName = newValue
      self.fieldLabel.text = _fieldName
      self.fieldLabel.sizeToFit()
      self.fieldLabel.hidden = !showField
      
      if showField && !(self.fieldLabel.superview != nil) {
        self.addSubview(self.fieldLabel)
      } else if !showField && (self.fieldLabel.superview != nil) {
        self.fieldLabel.removeFromSuperview()
      }
      
      if previous == nil || !(previous == _fieldName) {
        self.repositionViews()
      }
    }
  }
  
  public var fieldView: UIView? {
    get { return self._fieldView }
    set {
      if _fieldView == newValue {
        return
      }
      _fieldView?.removeFromSuperview()
      _fieldView = newValue
      if let _fieldView = _fieldView {
        self.addSubview(_fieldView)
      }
      self.repositionViews()
    }
  }
  
  public var placeholderText: String? {
    get { return _placeholderText }
    set {
      if _placeholderText == newValue {
        return
      }
      _placeholderText = newValue
      self.updatePlaceholderTextVisibility()
    }
  }
  
  public var accessoryView: UIView? {
    get { return _accessoryView }
    set {
      if _accessoryView == newValue {
        return
      }
      _accessoryView?.removeFromSuperview()
      _accessoryView = newValue
      _accessoryView?.hidden = true
      if let _accessoryView = _accessoryView {
        self.addSubview(_accessoryView)
      }
      self.repositionViews()
    }
  }
  
}

// Mark: Drawing
extension FA_TokenInputView {
  public var drawBottomBorder: Bool {
    get { return _drawBottomBorder }
    set {
      if _drawBottomBorder == newValue {
        return
      }
      _drawBottomBorder = newValue
      self.setNeedsDisplay()
    }
  }
  
  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
  override public func drawRect(rect: CGRect) {
    super.drawRect(rect)
    if self.drawBottomBorder {
      
      let context = UIGraphicsGetCurrentContext()
      let bounds = self.bounds
      CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor().CGColor)
      CGContextSetLineWidth(context, 0.5)
      
      CGContextMoveToPoint(context, 0, bounds.size.height)
      CGContextAddLineToPoint(context, CGRectGetWidth(bounds), bounds.size.height)
      CGContextStrokePath(context)
    }
  }
}


// MARK: - FA_TokenViewDelegate
extension FA_TokenInputView: FA_TokenViewDelegate {
  func tokenViewDidRequestDelete(tokenView: FA_TokenView, replaceWithText theText: String?) {
    if self.displayMode == .View {
      return
    }
    // First, refocus the text field
    self.textField.becomeFirstResponder()
    if !(theText?.isEmpty ?? true) {
      self.textField.text = theText
    }
    // Then remove the view from our data
    if let index = self.tokenViews.indexOf(tokenView) {
      self.removeTokenAtIndex(index)
    }
  }
  func tokenViewDidRequestSelection(tokenView: FA_TokenView) {
    self.selectTokenView(tokenView: tokenView, animated: true)
  }
  
  func tokenViewShouldDisplayMenu(tokenView: FA_TokenView) -> Bool {
    guard let should = self.delegate?.tokenInputViewShouldDisplayMenuItems?(self) else { return false }
    return should
  }
  
  func tokenViewMenuItems(tokenView: FA_TokenView) -> [UIMenuItem] {
    guard let items = self.delegate?.tokenInputViewMenuItems?(self, token: tokenView.token) else { return [] }
    return items
  }
}

// MARK: FA_BackspceDetectingTextfield delegate
extension FA_TokenInputView: FA_BackspaceDetectingTextFieldDelegate {
  func textFieldDidDeleteBackward(textField: UITextField) {
    // Delay selecting the next token slightly, so that on iOS 8
    // the deleteBackward on CLTokenView is not called immediately,
    // causing a double-delete
    dispatch_async(dispatch_get_main_queue(), {
      if textField.text?.isEmpty ?? true {
        
        if let tokenView = self.tokenViews.last {
          self.selectTokenView(tokenView: tokenView, animated: true)
          self.textField.resignFirstResponder()
        }
      }
    })
  }
}
