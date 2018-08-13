import UIKit

@objc open class FA_Token: NSObject {
    
    open var displayText: String
    open var baseObject: AnyObject
    open var textColor: UIColor?
    open var selectedTextColor: UIColor?
    open var selectedBackgroundColor: UIColor?
  
    public init(displayText theText: String, baseObject theObject: AnyObject, textColor: UIColor? = nil, selectedTextColor: UIColor? = nil, selectedBackgroundColor: UIColor? = nil) {
        self.displayText = theText
        self.baseObject = theObject
        self.textColor = textColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.selectedTextColor = selectedTextColor
    }
}

public func ==(lhs: FA_Token, rhs: FA_Token) -> Bool {
    return lhs.displayText == rhs.displayText
}
