

import Foundation


@objc public class FA_Token: NSObject {
    
    public var displayText: String!
    public var baseObject: AnyObject!
    
    public init(displayText theText: String, baseObject theObject: AnyObject) {
        self.displayText = theText
        self.baseObject = theObject
    }
}

public func ==(lhs: FA_Token, rhs: FA_Token) -> Bool {
    return lhs.displayText == rhs.displayText
}