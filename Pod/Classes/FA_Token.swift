

import Foundation


@objc open class FA_Token: NSObject {
    
    open var displayText: String!
    open var baseObject: AnyObject!
    
    public init(displayText theText: String, baseObject theObject: AnyObject) {
        self.displayText = theText
        self.baseObject = theObject
    }
}

public func ==(lhs: FA_Token, rhs: FA_Token) -> Bool {
    return lhs.displayText == rhs.displayText
}
