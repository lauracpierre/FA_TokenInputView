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
        
    }

    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        self.title = "TokenInputViewDemo"
        self.view.addSubview(toField)
        
        let views = [
            "to": toField,
            "topGuide": self.topLayoutGuide
        ] as [NSObject: AnyObject]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topGuide][to]", options: nil, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[to]|", options: nil, metrics: nil, views: views))
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        toField.beginEditing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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