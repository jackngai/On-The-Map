//
//  Helper.swift
//  On The Map
//
//  Created by Jack Ngai on 9/29/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

class Helper:UIViewController{
    func showAlert(alertTitle: String, alertMessage: String){
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
}