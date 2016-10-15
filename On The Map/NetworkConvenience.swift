//
//  NetworkConvenience.swift
//  On The Map
//
//  Created by Jack Ngai on 10/11/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

extension NetworkClient{
    
    func checkForExistingPin(segueIdentifier: String, viewController: UIViewController){
        // MARK: Overwrite Warning
        // If Object ID is populated, it means user already posted a pin
        // Give user option to overwrite by keeping Object ID populated
        // or add new pin by blanking the Object ID field
        if NetworkClient.sharedInstance().user.objectID != ""{
            let alertController = UIAlertController(title: nil, message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .Alert)
            let newPinAction = UIAlertAction(title: "Add New", style: .Cancel, handler: { (action:UIAlertAction) in
                NetworkClient.sharedInstance().user.objectID = ""
                viewController.performSegueWithIdentifier(segueIdentifier, sender: self)
            })
            
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default, handler: { (UIAlertAction) in
                viewController.performSegueWithIdentifier(segueIdentifier, sender: self)
            })
            
            alertController.addAction(newPinAction)
            alertController.addAction(overwriteAction)
            
            viewController.presentViewController(alertController, animated: false, completion: nil)
            

            
        }
    }
    
    func getStudentsLocation(update:()->Void = {}){
        
        performUIUpdatesOnMain({
            ActivityIndicator.show(loadingText: "Updating students location information.")
            
        })
        
        var parameters = [String:AnyObject]()
        
        parameters[Constants.Parse.ParameterKeys.limit] = 100 as AnyObject
        parameters[Constants.Parse.ParameterKeys.order] = "-updatedAt" as AnyObject
        
        let getStudentsLocationRequest = NetworkClient.sharedInstance().parseGet(parameters)
        
        NetworkClient.sharedInstance().startTask("Parse", request: getStudentsLocationRequest) { (result, error) in
            
            let dictionaries = result["results"] as! [[String:AnyObject]]
            
            for dictionary in dictionaries{
                let student = StudentInformation(dictionary: dictionary)
                self.students.append(student)
                
            }
            
            update()

            performUIUpdatesOnMain({ 
                ActivityIndicator.hide()

            })
            
        }
    }
    
    func deleteSessionAndLogout(dismissView:()->Void){
        ActivityIndicator.show(loadingText: "Logging Off")
        
        let fb = FBSDKLoginManager()
        fb.logOut()
        
        
        let deleteCookieRequest = NetworkClient.sharedInstance().udacityDelete()
        
        NetworkClient.sharedInstance().startTask("Udacity", request: deleteCookieRequest) { (result, error) in
            guard let session = result["session"] as? [String:String], let sessionID = session["id"] else {
                print("Unable to retrieve session ID")
                return
            }
            guard error == nil else {
                print(error)
                return
            }
            if sessionID == ""{
                performUIUpdatesOnMain({
                    ActivityIndicator.hide()
                    Alert.show("Logout Error", alertMessage: "Unable to delete session ID. Please try again.")
                })
            } else {
                performUIUpdatesOnMain({
                    ActivityIndicator.hide()
                    dismissView()
                })
            }
        }

    }
}