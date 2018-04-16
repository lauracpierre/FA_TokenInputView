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
    toField.tintColor = UIColor.red
    toField.fieldName = "To"
    toField.font = UIFont.systemFont(ofSize: 14.0)
    toField.fieldNameFont = UIFont.systemFont(ofSize: 13.0)
    toField.fieldNameColor = UIColor.green
    
    let button: AnyObject = UIButton(type: .contactAdd)
    if let button = button as? UIButton {
      toField.accessoryView = button
    }
    
    let leftButton: AnyObject = UIButton(type: .infoDark)
    if let leftButton = leftButton as? UIButton {
      toField.fieldView = leftButton
    }
    
    ccField = FA_TokenInputView()
    ccField.translatesAutoresizingMaskIntoConstraints = false
    ccField.placeholderText = "Enter a name"
    ccField.drawBottomBorder = true
    ccField.delegate = self
    ccField.tintColor = UIColor.blue
    ccField.fieldName = "Cc"
    
    bccField = FA_TokenInputView(mode: .view)
    bccField.translatesAutoresizingMaskIntoConstraints = false
    bccField.drawBottomBorder = true
    bccField.fieldName = "Bcc"
    
    let black = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
    let selected = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
    bccField.setColors(black, selectedTextColor: black, selectedBackgroundColor: selected)
    bccField.delegate = self
    
    
    let buttonright2: AnyObject = UIButton(type: .contactAdd)
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
    button1.setTitle("Zero Height", for: UIControlState())
    button1.addTarget(self, action: #selector(ViewController.setZeroHeightToField), for: .touchUpInside)
    button1.titleLabel?.backgroundColor = UIColor.red
    
    let button2 = UIButton()
    button2.translatesAutoresizingMaskIntoConstraints = false
    button2.setTitle("Auto Height", for: UIControlState())
    button2.addTarget(self, action: #selector(ViewController.setAutoHeightToField), for: .touchUpInside)
    button2.tintColor = toField.tintColor
    button2.titleLabel?.backgroundColor = UIColor.red
    
    let button3 = UIButton()
    button3.translatesAutoresizingMaskIntoConstraints = false
    button3.setTitle("Force tokenize", for: UIControlState())
    button3.addTarget(self, action: #selector(ViewController.forceTokenize), for: .touchUpInside)
    button3.tintColor = toField.tintColor
    button3.titleLabel?.backgroundColor = UIColor.red
    
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
    
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide][to][cc][bcc]-30-[b1]", options: .directionLeadingToTrailing, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[to]|", options: .directionLeftToRight, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cc]|", options: .directionLeftToRight, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bcc]|", options: .directionLeftToRight, metrics: nil, views: views))
    self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[b1]-[b2]-[b3]-|", options: .alignAllCenterY, metrics: nil, views: views))
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
    view.backgroundColor = UIColor.red
    
    self.toField.setInputAccessoryView(view)
    self.ccField.setInputAccessoryView(view)
    
    self.bccField.addToken(token: FA_Token(displayText: "some token", baseObject:"some object"	as AnyObject))
    self.bccField.addToken(token: FA_Token(displayText: "foo@bar.com", baseObject:"foo@bar.com"	as AnyObject))
    self.bccField.addToken(token: FA_Token(displayText: "longeremail@thisshouldoverflow.com", baseObject:"longeremail@thisshouldoverflow.com"	as AnyObject))

    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    toField.beginEditing()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc func setZeroHeightToField() {
    self.toField.setHeightToZero()
  }
  
  @objc func setAutoHeightToField() {
    self.toField.setHeightToAuto()
  }
  
  @objc func forceTokenize() {
    self.toField.forceTokenizeCurrentText()
    NSLog("just called validateCurrentTokendsadsa")
  }
  
  
}

extension ViewController: FA_TokenInputViewDelegate {
  
  func tokenInputViewDidAddToken(_ view: FA_TokenInputView, token theNewToken: FA_Token) {
    NSLog("new token");
  }
  
  func tokenInputViewDidBeginEditing(_ view: FA_TokenInputView) {
    
  }
  
  func tokenInputViewDidChangeHeight(_ view: FA_TokenInputView, height newHeight: CGFloat) {
    
  }
  
  func tokenInputViewDidChangeText(_ view: FA_TokenInputView, text theNewText: String) {
    
  }
  
  func tokenInputViewDidEnditing(_ view: FA_TokenInputView) {
    
  }
  
  func tokenInputViewDidRemoveToken(_ view: FA_TokenInputView, token removedToken: FA_Token) {
    
  }
  
  func tokenInputViewTokenForText(_ view: FA_TokenInputView, text searchToken: String) -> FA_Token? {
    return FA_Token(displayText: searchToken, baseObject: searchToken as AnyObject)
  }
  
  func tokenInputViewShouldDisplayMenuItems(_ view: FA_TokenInputView) -> Bool {
    return true
  }
  
  func tokenInputViewMenuItems(_ view: FA_TokenInputView, token: FA_Token) -> [UIMenuItem] {
    let menu = UIMenuItem(title: "Copy Email address", action: #selector(ViewController.copyFromMenu(_:)))
    return [menu]
  }
  
  @objc func copyFromMenu(_ sender: AnyObject) {
    NSLog("Copy from menu called")
  }
  
}
