//
//  FA_BackspaceDetectingTextField.swift
//  Pods
//
//  Created by Pierre LAURAC on 29/06/2015.
//
//

import Foundation

protocol FA_BackspaceDetectingTextFieldDelegate: class, UITextFieldDelegate {
    func textFieldDidDeleteBackward(textField: UITextField)
}

/**
* CLBackspaceDetectingTextField is a very simple subclass
* of UITextField that adds an extra delegate method to
* notify whenever the backspace key is pressed. Without
* this delegate method, it is not possible to detect
* if the backspace key is pressed while the textfield is
* empty.
*
* @since v1.0
*/
class FA_BackspaceDetectingTextField: UITextField {
    
    weak var extendedDelegate: FA_BackspaceDetectingTextFieldDelegate? {
        get { return self.delegate as? FA_BackspaceDetectingTextFieldDelegate }
        set { self.delegate = newValue }
    }
    
    override func deleteBackward() {
        self.extendedDelegate?.textFieldDidDeleteBackward(self)
        super.deleteBackward()
    }
    
    // On iOS 8.0, deleteBackward is not called anymore, so according to:
    // http://stackoverflow.com/a/25862878/9849
    // This method override should work
    func keyboardInputShouldDelete(textField: UITextField) -> Bool {
        let shouldDelete = true
        if textField.text?.isEmpty ?? true {
            self.deleteBackward()
        }
    
        return shouldDelete;
    }

}
