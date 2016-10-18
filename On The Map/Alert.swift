//
// Alert.swift
//  On The Map
//
//  Created by Jack Ngai on 9/29/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

class Alert:UIViewController{
    
    internal static var alertController:UIAlertController!
    
    internal static func show(alertTitle: String, alertMessage: String, viewController: UIViewController){
        alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(action)
        
        
        // Hide Activity Indicator before showing the alert
        ActivityIndicator.hide()

        viewController.presentViewController(Alert.alertController, animated: true, completion: nil)
    }
}