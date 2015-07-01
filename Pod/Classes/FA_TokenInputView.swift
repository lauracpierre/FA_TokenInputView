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
        get {
            return self.tokens.map { $0 }
        }
    }
    var text: String {
        get { return self.textField.text }
    }

    var editing: Bool {
        get { return self.textField.editing }
    }
    
    public var font: UIFont! {
        didSet {
            self.fieldLabel?.font = self.font
            self.textField?.font = self.font
        }
    }
    
    
    private var tokens: [FA_Token] = []
    private var tokenViews: [FA_TokenView] = []
    private var textField: UITextField!
    private var fieldLabel: UILabel!
    private var intrinsicContentHeight: CGFloat!
    private var heightZeroConstraint: NSLayoutConstraint!
    
    private static var HSPACE: CGFloat = 0.0
    private static var TEXT_FIELD_HSPACE: CGFloat = 4.0
    private static var VSPACE: CGFloat = 4.0
    private static var MINIMUM_TEXTFIELD_WIDTH: CGFloat = 56.0
    private static var PADDING_TOP: CGFloat = 10.0
    private static var PADDING_BOTTOM: CGFloat = 10.0
    private static var PADDING_LEFT: CGFloat = 8.0
    private static var PADDING_RIGHT: CGFloat = 16.0
    private static var STANDARD_ROW_HEIGHT: CGFloat = 25.0
    private static var FIELD_MARGIN_X: CGFloat = 4.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() {
        
        self.font = UIFont.systemFontOfSize(17.0)
        self.textField = UITextField(frame: self.bounds)
        self.textField.backgroundColor = UIColor.clearColor()
        self.textField.keyboardType = self.keyboardType;
        self.textField.autocorrectionType = self.autocorrectionType;
        self.textField.autocapitalizationType = self.autocapitalizationType;
        self.textField.delegate = self
        self.textField.addTarget(self, action: "onTextFieldDidChange:", forControlEvents: .EditingChanged)
        self.addSubview(self.textField)
        
        self.fieldLabel = UILabel(frame: CGRectZero)
        self.fieldLabel.textColor = UIColor.lightGrayColor()
        self.addSubview(self.fieldLabel)
        self.fieldLabel.hidden = true
        
        self.backgroundColor = UIColor.clearColor()
        self.intrinsicContentHeight = FA_TokenInputView.STANDARD_ROW_HEIGHT
        self.repositionViews()
        self.backgroundColor = UIColor.whiteColor()
        
        self.heightZeroConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0.0)
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, max(45, self.intrinsicContentHeight))
    }
    
    override public func tintColorDidChange() {
        for view in self.tokenViews {
            view.tintColor = self.tintColor
        }
    }
    
    public func addToken(token theToken: FA_Token) {
        if contains(self.tokens, theToken) {
            return
        }
        
        
        self.tokens.append(theToken)
        var tokenView = FA_TokenView(token: theToken)
        tokenView.font = self.font
        if let tint = self.tintColor {
            tokenView.setTintColor(color: tint)
        }
        tokenView.delegate = self;
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
    
    public func removeToken(token theToken: FA_Token) {
        if let index = find(self.tokens, theToken) {
            self.removeTokenAtIndex(index)
        }
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
    
    func tokenizeTextFieldText() -> FA_Token? {

        let text = self.textField.text;
        if !text.isEmpty {
            if let token = self.delegate?.tokenInputViewTokenForText?(self, text: text) {
                self.addToken(token: token)
                self.onTextFieldDidChange(self.textField)
                return token
            }
        }
        
        return nil
    }
    
    func textFieldDisplayOffset() -> CGFloat {
        // Essentially the textfield's y with PADDING_TOP
        return CGRectGetMinY(self.textField.frame) - FA_TokenInputView.PADDING_TOP
    }
    
    func repositionViews() {
        let bounds = self.bounds
        
        if bounds.height == 0 {
            self.repositionViewZeroHeight()
            return
        }
        
        var rightBoundary = CGRectGetWidth(bounds) - FA_TokenInputView.PADDING_RIGHT
        var firstLineRightBoundary = rightBoundary
        
        var curX = FA_TokenInputView.PADDING_LEFT
        var curY = FA_TokenInputView.PADDING_TOP
        var totalHeight = FA_TokenInputView.STANDARD_ROW_HEIGHT
        var isOnFirstLine = true
        
        // Position field view (if set)
        if let fieldView = self.fieldView {
            fieldView.sizeToFit()
            var fieldViewRect = fieldView.frame
            fieldViewRect.origin.x = curX + FA_TokenInputView.FIELD_MARGIN_X
            fieldViewRect.origin.y = curY + ((FA_TokenInputView.STANDARD_ROW_HEIGHT - CGRectGetHeight(fieldViewRect))/2.0)
            fieldView.frame = fieldViewRect
            
            curX = CGRectGetMaxX(fieldViewRect) + FA_TokenInputView.FIELD_MARGIN_X
        }
        
        // Position field label (if field name is set)
        if !self.fieldLabel.hidden {
            self.fieldLabel.sizeToFit()
            var fieldLabelRect = self.fieldLabel.frame
            fieldLabelRect.origin.x = curX + FA_TokenInputView.FIELD_MARGIN_X
            fieldLabelRect.origin.y = curY + ((FA_TokenInputView.STANDARD_ROW_HEIGHT-CGRectGetHeight(fieldLabelRect))/2.0)
            self.fieldLabel.frame = fieldLabelRect
            
            curX = CGRectGetMaxX(fieldLabelRect) + FA_TokenInputView.FIELD_MARGIN_X
        }
        
        // Position accessory view (if set)
        if let accessoryView = self.accessoryView {
            accessoryView.sizeToFit()
            var accessoryRect = accessoryView.frame
            accessoryRect.origin.x = CGRectGetWidth(bounds) - FA_TokenInputView.PADDING_RIGHT - CGRectGetWidth(accessoryRect)
            accessoryRect.origin.y = curY
            accessoryView.frame = accessoryRect
            
            firstLineRightBoundary = CGRectGetMinX(accessoryRect) - FA_TokenInputView.HSPACE
        }
        
        // Position token views
        var tokenRect = CGRectNull
        for view in self.tokenViews {
            view.sizeToFit()
            tokenRect = view.frame
            
            let tokenBoundary = isOnFirstLine ? firstLineRightBoundary : rightBoundary
            if (curX + CGRectGetWidth(tokenRect) > tokenBoundary) {
                // Need a new line
                curX = FA_TokenInputView.PADDING_LEFT
                curY += FA_TokenInputView.STANDARD_ROW_HEIGHT+FA_TokenInputView.VSPACE
                totalHeight += FA_TokenInputView.STANDARD_ROW_HEIGHT
                isOnFirstLine = false
            }
            
            tokenRect.origin.x = curX
            // Center our tokenView vertially within STANDARD_ROW_HEIGHT
            tokenRect.origin.y = curY + ((FA_TokenInputView.STANDARD_ROW_HEIGHT-CGRectGetHeight(tokenRect))/2.0)
            view.frame = tokenRect
            
            curX = CGRectGetMaxX(tokenRect) + FA_TokenInputView.HSPACE
        }
        
        // Always indent textfield by a little bit
        curX += FA_TokenInputView.TEXT_FIELD_HSPACE
        let textBoundary = isOnFirstLine ? firstLineRightBoundary : rightBoundary
        var availableWidthForTextField = textBoundary - curX
        if availableWidthForTextField < FA_TokenInputView.MINIMUM_TEXTFIELD_WIDTH {
            isOnFirstLine = false
            curX = FA_TokenInputView.PADDING_LEFT + FA_TokenInputView.TEXT_FIELD_HSPACE
            curY += FA_TokenInputView.STANDARD_ROW_HEIGHT+FA_TokenInputView.VSPACE
            totalHeight += FA_TokenInputView.STANDARD_ROW_HEIGHT
            // Adjust the width
            availableWidthForTextField = rightBoundary - curX
        }
        
        var textFieldRect = self.textField.frame
        textFieldRect.origin.x = curX
        textFieldRect.origin.y = curY
        textFieldRect.size.width = availableWidthForTextField
        textFieldRect.size.height = FA_TokenInputView.STANDARD_ROW_HEIGHT
        self.textField.frame = textFieldRect
        
        let oldContentHeight = self.intrinsicContentHeight
        self.intrinsicContentHeight = CGRectGetMaxY(textFieldRect)+FA_TokenInputView.PADDING_BOTTOM
        self.invalidateIntrinsicContentSize()
        
        if (oldContentHeight != self.intrinsicContentHeight) {
            self.delegate?.tokenInputViewDidChangeHeight?(self, height: self.intrinsicContentSize().height)
        }
        self.setNeedsDisplay()

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
    
    

    func updatePlaceholderTextVisibility() {
        if self.tokens.isEmpty {
            self.textField.placeholder = self.placeholderText
        } else {
            self.textField.placeholder = nil
        }
    }
    
    func onTextFieldDidChange(textfield: UITextField) {
        self.delegate?.tokenInputViewDidChangeText?(self, text: textfield.text)
    }
    
    public func setHeightToZero() {
        self.addConstraint(self.heightZeroConstraint)
    }
    
    public func setHeightToAuto() {
        self.removeConstraint(self.heightZeroConstraint)
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
        self.textField.becomeFirstResponder()
        self.unselectAllTokenViewsAnimated(false)
    }
    
    public func endEditing() {
        self.resignFirstResponder()
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
        // First, refocus the text field
        self.textField.becomeFirstResponder()
        if !(theText?.isEmpty ?? true) {
            self.textField.text = theText
        }
        // Then remove the view from our data
        if let index = find(self.tokenViews, tokenView) {
            self.removeTokenAtIndex(index)
        }
    }
    func tokenViewDidRequestSelection(tokenView: FA_TokenView) {
        self.selectTokenView(tokenView: tokenView, animated: true)
    }
}


