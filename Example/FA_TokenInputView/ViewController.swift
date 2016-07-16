//
//  ViewController.swift
//  FA_TokenInputView
//
//  Created by Pierre Laurac on 06/29/2015.
//  Copyright (c) 06/29/2015 Pierre Laurac. All rights reserved.
//

import UIKit
import FA_TokenInputView

class ViewController: UIViewController {
  
  var toField: FA_TokenInputView!
  
  var ccField: FA_TokenInputView!
  
  var bccField: FA_TokenInputView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    toField = FA_TokenInputView()
    toField.translatesAutoresizingMaskIntoConstraints = false
    toField.placeholderText = "Enter a name"
    toField.drawBottomBorder = true
    toField.delegate = self
    toField.tintColor = UIColor.redColor()
    toField.fieldName = "To"
    toField.font = UIFont.systemFontOfSize(14.0)
    toField.fieldNameFont = UIFont.systemFontOfSize(13.0)
    toField.fieldNameColor = UIColor.greenColor()
    
    let button: AnyObject = UIButton(type: .ContactAdd)
    if let button = button as? UIButton {
      toField.accessoryView = button
    }
    
    let leftButton: AnyObject = UIButton(type: .InfoDark)
    if let leftButton = leftButton as? UIButton {
      toField.fieldView = leftButton
    }
    
    ccField = FA_TokenInputView()
    ccField.translatesAutoresizingMaskIntoConstraints = false
    ccField.placeholderText = "Enter a name"
    ccField.drawBottomBorder = true
    ccField.delegate = self
    ccField.tintColor = UIColor.blueColor()
    ccField.fieldName = "Cc"
    
    bccField = FA_TokenInputView(mode: .View)
    bccField.translatesAutoresizingMaskIntoConstraints = false
    bccField.drawBottomBorder = true
    bccField.fieldName = "Bcc"
    
    let black = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
    let selected = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
    bccField.setColors(black, selectedTextColor: black, selectedBackgroundColor: selected)
    bccField.delegate = self
    
    
    let buttonright2: AnyObject = UIButton(type: .ContactAdd)
    if let buttonright2 = buttonright2 as? UIButton {
      ccField.accessoryView = buttonright2
    }
    
  }
  
  override func viewDidLoad() {
    
    
    super.viewDidLoad()
    
    self.title = "TokenInputViewDemo"
    self.view.addSubview(toField)
    self.view.addSubview(ccField)
    self.view.addSubview(bccField)
    
    let button1 = UIButton()
    button1.translatesAutoresizingMaskIntoConstraints = false
    button1.setTitle("Zero Height", forState: .Normal)
    button1.addTarget(self, action: #selector(ViewController.setZeroHeightToField), forControlEvents: .TouchUpInside)
    button1.titleLabel?.backgroundColor = UIColor.redColor()
    
    let button2 = UIButton()
    button2.translatesAutoresizingMaskIntoConstraints = false
    button2.setTitle("Auto Height", forState: .Normal)
    button2.addTarget(self, action: #selector(ViewController.setAutoHeightToField), forControlEvents: .TouchUpInside)
    button2.tintColor = toField.tintColor
    button2.titleLabel?.backgroundColor = UIColor.redColor()
    
    let button3 = UIButton()
    button3.translatesAutoresizingMaskIntoConstraints = false
    button3.setTitle("Force tokenize", forState: .Normal)
    button3.addTarget(self, action: #selector(ViewController.forceTokenize), forControlEvents: .TouchUpInside)
    button3.tintColor = toField.tintColor
    button3.titleLabel?.backgroundColor = UIColor.redColor()
    
    self.view.addSubview(button1)
    self.view.addSubview(button2)
    self.view.addSubview(button3)
    
    let views = [
      "to": toField,
      "cc": ccField,
      "bcc": bccField,
      "b1": button1,
      "b2": button2,
      "b3": button3,
      "topGuide": self.topLayoutGuide
      ] as [String: AnyObject]
    
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topGuide][to][cc][bcc]-30-[b1]", options: .DirectionLeadingToTrailing, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[to]|", options: .DirectionLeftToRight, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cc]|", options: .DirectionLeftToRight, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bcc]|", options: .DirectionLeftToRight, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[b1]-[b2]-[b3]-|", options: .AlignAllCenterY, metrics: nil, views: views))
    
    let view = UIView(frame: CGRectMake(0, 0, 200, 45))
    view.backgroundColor = UIColor.redColor()
    
    self.toField.setInputAccessoryView(view)
    self.ccField.setInputAccessoryView(view)
    
    self.bccField.addToken(token: FA_Token(displayText: "some token", baseObject:"some object"))
    self.bccField.addToken(token: FA_Token(displayText: "foo@bar.com", baseObject:"foo@bar.com"))
    self.bccField.addToken(token: FA_Token(displayText: "longeremail@thisshouldoverflow.com", baseObject:"longeremail@thisshouldoverflow.com"))

    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewDidAppear(animated: Bool) {
    toField.beginEditing()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setZeroHeightToField() {
    self.toField.setHeightToZero()
  }
  
  func setAutoHeightToField() {
    self.toField.setHeightToAuto()
  }
  
  func forceTokenize() {
    self.toField.forceTokenizeCurrentText()
    NSLog("just called validateCurrentTokendsadsa")
  }
  
  
}

extension ViewController: FA_TokenInputViewDelegate {
  
  func tokenInputViewDidAddToken(view: FA_TokenInputView, token theNewToken: FA_Token) {
    NSLog("new token");
  }
  
  func tokenInputViewDidBeginEditing(view: FA_TokenInputView) {
    
  }
  
  func tokenInputViewDidChangeHeight(view: FA_TokenInputView, height newHeight: CGFloat) {
    
  }
  
  func tokenInputViewDidChangeText(view: FA_TokenInputView, text theNewText: String) {
    
  }
  
  func tokenInputViewDidEnditing(view: FA_TokenInputView) {
    
  }
  
  func tokenInputViewDidRemoveToken(view: FA_TokenInputView, token removedToken: FA_Token) {
    
  }
  
  func tokenInputViewTokenForText(view: FA_TokenInputView, text searchToken: String) -> FA_Token? {
    return FA_Token(displayText: searchToken, baseObject: searchToken)
  }
  
  func tokenInputViewShouldDisplayMenuItems(view: FA_TokenInputView) -> Bool {
    return true
  }
  
  func tokenInputViewMenuItems(view: FA_TokenInputView, token: FA_Token) -> [UIMenuItem] {
    let menu = UIMenuItem(title: "Copy Email address", action: #selector(ViewController.copyFromMenu(_:)))
    return [menu]
  }
  
  func copyFromMenu(sender: AnyObject) {
    NSLog("Copy from menu called")
  }
  
}