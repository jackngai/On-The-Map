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
    
    internal static func show(alertTitle: String, alertMessage: String){
        alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(action)
        
        
        // Hide Activity Indicator before showing the alert
        ActivityIndicator.hide()
        
        if let controller = UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController{
            controller.presentViewController(Alert.alertController, animated: true, completion: nil)
        } else {
//            if let window = UIApplication.sharedApplication().delegate?.window{
//                window?.rootViewController?.presentViewController(Alert.alertController, animated: true){
//                }
//                
//                
//                
//                
//                //, completion: nil)
//                
//                
//            }
             UIApplication.sharedApplication().delegate?.window!!.rootViewController?.presentViewController(Alert.alertController, animated: true, completion: nil)
        }
    }
}