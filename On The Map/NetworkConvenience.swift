//
//  NetworkConvenience.swift
//  On The Map
//
//  Created by Jack Ngai on 10/11/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

extension NetworkClient{
    
    func getStudentsLocation(){
        var parameters = [String:AnyObject]()
        
        parameters[Constants.Parse.ParameterKeys.limit] = 100 as AnyObject
        parameters[Constants.Parse.ParameterKeys.order] = "-updatedAt" as AnyObject
        
        let getStudentsLocationRequest = NetworkClient.sharedInstance().parseGet(parameters)
        
        NetworkClient.sharedInstance().startTask("Parse", request: getStudentsLocationRequest) { (result, error) in
            
            let dictionaries = result["results"] as! [[String:AnyObject]]
            
            for dictionary in dictionaries{
                let student = StudentInformation(dictionary: dictionary)
                self.students.append(student)
                
                // MARK: Test Code
                //print(student.firstName)
                
                // end test code
                
            }
            // MARK: Test Code
            //print(self.students)
            
            // end test code
            performUIUpdatesOnMain({ 
                //LoadingIndicatorView.hide()

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