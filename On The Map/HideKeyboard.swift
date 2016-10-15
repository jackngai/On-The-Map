//
//  HideKeyboard.swift
//  On The Map
//
//  Created by Jack Ngai on 10/12/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

// Hide the keyboard when user taps somewhere on screen

extension UIViewController {
    func tapScreenToHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}