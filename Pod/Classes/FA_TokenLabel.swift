//
//  FA_TokenLabel.swift
//  Pods
//
//  Created by Pierre Laurac on 9/14/16.
//
//

import Foundation

class FA_TokenLabel: UILabel {
  
  override func canBecomeFirstResponder() -> Bool {
    return true
  }
  
  override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
    return false
  }
}