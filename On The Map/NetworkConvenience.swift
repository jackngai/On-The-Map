//
//  NetworkConvenience.swift
//  On The Map
//
//  Created by Jack Ngai on 10/1/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension NetworkClient {
    
    // MARK: Authentication (GET) Methods
    /*
     Steps for Authentication...
     https://www.themoviedb.org/documentation/api/sessions
     
     Step 1: Create a new request token
     Step 2a: Ask the user for permission via the website
     Step 3: Create a session ID
     Bonus Step: Go ahead and get the user id 😄!
     */
    func authenticateWithViewController(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        // chain completion handlers for each request so that they run one after the other
        getRequestToken() { (success, requestToken, errorString) in
            
            if success {
                
                // success! we have the requestToken!
                print(requestToken)
                self.requestToken = requestToken
                
                self.loginWithToken(requestToken, hostViewController: hostViewController) { (success, errorString) in
                    
                    if success {
                        self.getSessionID(requestToken) { (success, sessionID, errorString) in
                            
                            if success {
                                
                                // success! we have the sessionID!
                                self.sessionID = sessionID
                                
                                self.getUserID() { (success, userID, errorString) in
                                    
                                    if success {
                                        
                                        if let userID = userID {
                                            
                                            // and the userID 😄!
                                            self.userID = userID
                                        }
                                    }
                                    
                                    completionHandlerForAuth(success: success, errorString: errorString)
                                }
                            } else {
                                completionHandlerForAuth(success: success, errorString: errorString)
                            }
                        }
                    } else {
                        completionHandlerForAuth(success: success, errorString: errorString)
                    }
                }
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }
    
    private func getRequestToken(completionHandlerForToken: (success: Bool, requestToken: String?, errorString: String?) -> Void) {
        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [String:AnyObject]()
//        
//        /* 2. Make the request */
//        taskForGETMethod(Methods.AuthenticationTokenNew, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                print(error)
//                completionHandlerForToken(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
//            } else {
//                if let requestToken = results[Constants.JSONResponseKeys.RequestToken] as? String {
//                    completionHandlerForToken(success: true, requestToken: requestToken, errorString: nil)
//                } else {
//                    print("Could not find \(Constants.JSONResponseKeys.RequestToken) in \(results)")
//                    completionHandlerForToken(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
//                }
//            }
//        }
    }
    
    private func loginWithToken(requestToken: String?, hostViewController: UIViewController, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
//        
//        let authorizationURL = NSURL(string: "\(Constants.AuthorizationURL)\(requestToken!)")
//        let request = NSURLRequest(URL: authorizationURL!)
//        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("NetworkAuthViewController") as! NetworkAuthViewController
//        webAuthViewController.urlRequest = request
//        webAuthViewController.requestToken = requestToken
//        webAuthViewController.completionHandlerForView = completionHandlerForLogin
//        
//        let webAuthNavigationController = UINavigationController()
//        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
//        
//        performUIUpdatesOnMain {
//            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
//        }
    }
    
    private func getSessionID(requestToken: String?, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [Constants.ParameterKeys.RequestToken: requestToken!]
//        
//        /* 2. Make the request */
//        taskForGETMethod(Methods.AuthenticationSessionNew, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                print(error)
//                completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
//            } else {
//                if let sessionID = results[Constants.JSONResponseKeys.SessionID] as? String {
//                    completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
//                } else {
//                    print("Could not find \(Constants.JSONResponseKeys.SessionID) in \(results)")
//                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
//                }
//            }
//        }
    }
    
    private func getUserID(completionHandlerForUserID: (success: Bool, userID: Int?, errorString: String?) -> Void) {
        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [Constants.ParameterKeys.SessionID: NetworkClient.sharedInstance().sessionID!]
//        
//        /* 2. Make the request */
//        taskForGETMethod(Methods.Account, parameters: parameters) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                print(error)
//                completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
//            } else {
//                if let userID = results?[NetworkClient.JSONResponseKeys.UserID] as? Int {
//                    completionHandlerForUserID(success: true, userID: userID, errorString: nil)
//                } else {
//                    print("Could not find \(NetworkClient.JSONResponseKeys.UserID) in \(results)")
//                    completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
//                }
//            }
        //        }
    }
    


}