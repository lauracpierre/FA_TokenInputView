//
//  FA_TokenView.swift
//  Pods
//
//  Created by Pierre LAURAC on 29/06/2015.
//
//

import Foundation

protocol FA_TokenViewDelegate: class {
    func tokenViewDidRequestDelete(tokenView: FA_TokenView, replaceWithText theText: String?)
    func tokenViewDidRequestSelection(tokenView: FA_TokenView)
}

class FA_TokenView: UIView {
    
    var displayText: String!
    var autocorrectionType: UITextAutocorrectionType = .No
    
    weak var delegate: FA_TokenViewDelegate?
    private(set) var selected = false
    
    
    private static let PADDING_X: CGFloat = 4.0
    private static let PADDING_Y: CGFloat = 2.0
    private var label: UILabel!
    private var selectedBackgroundView: UIView!
    private var selectedLabel: UILabel!
    
    var font: UIFont! {
        didSet {
            self.label.font = self.font
            self.selectedLabel.font = self.font
        }
    }
    
    init(token theToken: FA_Token) {
        super.init(frame: CGRectZero)
        
        var tintColor = UIColor(red: 0.0823, green: 0.4941, blue: 0.9843, alpha: 1.0)
        if let tint = self.tintColor {
            tintColor = tint
        }
        self.label = UILabel(frame: CGRectMake(FA_TokenView.PADDING_X, FA_TokenView.PADDING_Y, 0, 0))
        self.label.textColor = tintColor
        self.label.backgroundColor = UIColor.clearColor()
        self.addSubview(label)
        
        self.selectedBackgroundView = UIView(frame: CGRectZero)
        self.selectedBackgroundView.backgroundColor = tintColor
        self.selectedBackgroundView.layer.cornerRadius = 3.0
        self.selectedBackgroundView.hidden = true
        self.addSubview(self.selectedBackgroundView)
        
        self.selectedLabel = UILabel(frame: CGRectMake(FA_TokenView.PADDING_X, FA_TokenView.PADDING_Y, 0, 0))
        self.selectedLabel.textColor = UIColor.whiteColor()
        self.selectedLabel.backgroundColor = UIColor.clearColor()
        self.selectedLabel.hidden = true
        self.addSubview(self.selectedLabel)
        
        
        self.displayText = theToken.displayText
        
        // Configure for the token, unselected shows "[displayText]," and selected is "[displayText]"
        let labelString = "\(self.displayText),"
        let attrString = NSMutableAttributedString(string: labelString, attributes: [
                NSFontAttributeName : self.label.font,
                NSForegroundColorAttributeName : UIColor.lightGrayColor()
            ])
        let tintRange = (labelString as NSString).rangeOfString(self.displayText)

        // Make the name part the system tint color
        attrString.setAttributes([NSForegroundColorAttributeName : tintColor], range: tintRange)
        
        self.label.attributedText = attrString
        self.selectedLabel.text = self.displayText
        
        // Listen for taps
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        self.addGestureRecognizer(tapGesture)
        self.setNeedsLayout()

    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func intrinsicContentSize() -> CGSize {
        let size = self.selectedLabel.intrinsicContentSize()
        return CGSizeMake(size.width+(2.0*FA_TokenView.PADDING_X), size.height+(2.0*FA_TokenView.PADDING_Y))
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let fittingSize = CGSizeMake(size.width-(2.0*FA_TokenView.PADDING_X), size.height-(2.0*FA_TokenView.PADDING_Y))
        let labelSize = self.selectedLabel.sizeThatFits(fittingSize)
        return CGSizeMake(labelSize.width+(2.0*FA_TokenView.PADDING_X), labelSize.height+(2.0*FA_TokenView.PADDING_Y))
    }
    
    func setSelected(selected selectedValue: Bool, animated: Bool) {
        if (self.selected == selectedValue) {
            return
        }
        
        selected = selectedValue;
        
        if (selected) {
            self.becomeFirstResponder()
        }
        
        let selectedAlpha: CGFloat = self.selected ? 1.0 : 0.0
        if (animated) {
            if (self.selected) {
                self.selectedBackgroundView.alpha = 0.0
                self.selectedBackgroundView.hidden = false
                self.selectedLabel.alpha = 0.0
                self.selectedLabel.hidden = false
            }
            UIView.animateWithDuration(0.25, animations: {
                self.selectedBackgroundView.alpha = selectedAlpha
                self.selectedLabel.alpha = selectedAlpha
            }, completion: { (_) in
                if !self.selected {
                    self.selectedBackgroundView.hidden = true
                    self.selectedLabel.hidden = true
                }
            })
    
        } else {
            self.selectedBackgroundView.hidden = !self.selected;
            self.selectedLabel.hidden = !self.selected;
        }
    }
    
    func setTintColor(color theColor: UIColor) {
        if self.tintColor != nil {
            super.tintColor = theColor
        }
        self.label.textColor = tintColor
        self.selectedBackgroundView.backgroundColor = tintColor
        let attrString: AnyObject = self.label.attributedText!.mutableCopy()
        let labelString = "\(self.displayText),"
        let tintRange = (labelString as NSString).rangeOfString(self.displayText)
        // Make the overall text color gray
        attrString.setAttributes([NSForegroundColorAttributeName: UIColor.lightGrayColor()], range:NSMakeRange(0, attrString.length))
        // Make the name part the system tint color
        attrString.setAttributes([NSForegroundColorAttributeName : tintColor], range:tintRange)
        if let attrString = attrString as? NSAttributedString {
            self.label.attributedText = attrString
        }
        
    }
    
    func handleTapGestureRecognizer(recognizer: UITapGestureRecognizer) {
        self.delegate?.tokenViewDidRequestSelection(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        //self.backgroundView.frame = bounds
        self.selectedBackgroundView.frame = bounds
        
        var labelFrame = CGRectInset(bounds, FA_TokenView.PADDING_X, FA_TokenView.PADDING_Y)
        self.selectedLabel.frame = labelFrame;
        labelFrame.size.width += FA_TokenView.PADDING_X*2.0;
        self.label.frame = labelFrame;

    }

    
}

extension FA_TokenView: UIKeyInput {
    func hasText() -> Bool {
        return true
    }
    
    func insertText(text: String) {
        self.delegate?.tokenViewDidRequestDelete(self, replaceWithText: text)
    }
    
    func deleteBackward() {
        self.delegate?.tokenViewDidRequestDelete(self, replaceWithText: nil)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
}