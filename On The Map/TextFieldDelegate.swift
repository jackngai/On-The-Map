//
//  TextFieldDelegate.swift
//  On The Map
//
//  Created by Jack Ngai on 10/12/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import Foundation
import UIKit

// Hide keyboard when textfield is no longer in focus

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}