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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        toField = FA_TokenInputView()
        toField.setTranslatesAutoresizingMaskIntoConstraints(false)
        toField.placeholderText = "Enter a name"
        toField.drawBottomBorder = true
        toField.delegate = self
        toField.tintColor = UIColor.redColor()
        toField.fieldName = "To"
        
        var button: AnyObject = UIButton.buttonWithType(.ContactAdd)
        if let button = button as? UIButton {
            toField.accessoryView = button
        }
        
        var leftButton: AnyObject = UIButton.buttonWithType(.InfoDark)
        if let leftButton = leftButton as? UIButton {
            toField.fieldView = leftButton
        }
        
        ccField = FA_TokenInputView()
        ccField.setTranslatesAutoresizingMaskIntoConstraints(false)
        ccField.placeholderText = "Enter a name"
        ccField.drawBottomBorder = true
        ccField.delegate = self
        ccField.tintColor = UIColor.blueColor()
        ccField.fieldName = "Cc"
        
        var buttonright2: AnyObject = UIButton.buttonWithType(.ContactAdd)
        if let buttonright2 = buttonright2 as? UIButton {
            ccField.accessoryView = buttonright2
        }
        
    }

    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        self.title = "TokenInputViewDemo"
        self.view.addSubview(toField)
        self.view.addSubview(ccField)
        
        var button1 = UIButton()
        button1.setTranslatesAutoresizingMaskIntoConstraints(false)
        button1.setTitle("Zero Height", forState: .Normal)
        button1.addTarget(self, action: "setZeroHeightToField", forControlEvents: .TouchUpInside)
        button1.titleLabel?.backgroundColor = UIColor.redColor()
        
        var button2 = UIButton()
        button2.setTranslatesAutoresizingMaskIntoConstraints(false)
        button2.setTitle("Auto Height", forState: .Normal)
        button2.addTarget(self, action: "setAutoHeightToField", forControlEvents: .TouchUpInside)
        button2.tintColor = toField.tintColor
        button2.titleLabel?.backgroundColor = UIColor.redColor()
        
        self.view.addSubview(button1)
        self.view.addSubview(button2)
        
        let views = [
            "to": toField,
            "cc": ccField,
            "b1": button1,
            "b2": button2,
            "topGuide": self.topLayoutGuide
        ] as [NSObject: AnyObject]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topGuide][to][cc]-30-[b1]", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[to]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[cc]|", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[b1]-[b2]-|", options: .AlignAllCenterY, metrics: nil, views: views))
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
        toField.setHeightToZero()
    }
    
    func setAutoHeightToField() {
        toField.setHeightToAuto()
    }

}

extension ViewController: FA_TokenInputViewDelegate {
    
    func tokenInputViewDidAddToken(view: FA_TokenInputView, token theNewToken: FA_Token) {
        
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
}