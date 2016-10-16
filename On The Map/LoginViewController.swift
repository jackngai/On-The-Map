//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/23/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    // MARK: Properties
    private let textFieldDelgate = TextFieldDelegate()
    
    private var viewShiftedUp = false
    
    private var fbToken:String!
    
    // MARK: Lifecycle methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Clear out password and username text fields in case this is coming from the logout button
        self.emailField.text = nil
        self.passwordField.text = nil
        
        // Notify when keyboard is shown/hidden; call method to shift view up/down
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil){ notification in self.moveViewForKeyboard(notification) }
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil){ notification in self.moveViewForKeyboard(notification) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call method to enable hiding keyboard when screen is tapped
        self.tapScreenToHideKeyboard()
        
        // Set Facebook login delegate
        fbLoginButton.delegate = self
        
        
        let fb = FBSDKLoginManager()
        fb.logOut()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop receiving notification for showing/hiding keyboard
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    

    // Login using username/password fields
    @IBAction func tappedLoginButton(sender: UIButton) {
        
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        ActivityIndicator.show(loadingText: "Authenticating Credentials")
        completeLogin()
 
 
    }
    
    @IBAction func signUp(sender: UIButton) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.udacity.com")!)
    }

    

    // MARK: Methods
    
    // Login using Facebook
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        ActivityIndicator.show(loadingText: "Authenticating using Facebook")
        
        guard let token = FBSDKAccessToken.currentAccessToken(), let tokenString = token.tokenString else{
            ActivityIndicator.hide()
            Alert.show("Unable to login with Facebook", alertMessage: "Did not receive access token from Facebook. Might be a network error or a FB credentials error. Please try again.", viewController: self)
            print("No token received from Facebook")
            return
        }
        
        fbToken = tokenString
        
        completeLogin()
    }
    
    private func completeLogin(){
        
        // MARK: Authentication
        
        // Create a blank NSMutableURLRequest
        var authenticationRequest:NSMutableURLRequest!
        
        // Use email/password to populate authenticationRequest as long as they are not blank
        // If they are blank, populate authenticationRequest using fbToken
        if let username = emailField.text, let password = passwordField.text where username != "" && password != ""{
            authenticationRequest = NetworkClient.sharedInstance().udacityPOST(username, password: password)
        } else if let fbToken = fbToken{
            authenticationRequest = NetworkClient.sharedInstance().udacityPOST(fbToken: fbToken)
        } else {
            print("Username/password field missing or failed to retrieve Facebook access token.")
            return
        }

        
        // Start request
        
        NetworkClient.sharedInstance().startTask("Udacity", request: authenticationRequest) { (result, error) in
            
            guard error == nil else {
                print("Error authenticating: \(error)")
                return
            }
            
            // Unwrap and look for account key (User Unique Key)
            guard let accountInfo = result["account"], let optionalKey = accountInfo?["key"], let key = optionalKey as? String else {
                print("Unable to retrieve key from parsed result.")
                return
            }
            
            // Populate uniqueKey field so it can be used later
            NetworkClient.sharedInstance().user.uniqueKey = key
            
            // Get the session ID
            
            guard let sessionInfo = result["session"], let optionalSessionID = sessionInfo?["id"], let sessionID = optionalSessionID as? String else{
                print("Unable to retrieve session ID from parsed result.")
                return
            }
            
            // Get user's public information (first name, last name) using the unique key
            // we received earlier during authentication
            
            let getUserPublicInfoRequest = NetworkClient.sharedInstance().udacityGET()
            
            NetworkClient.sharedInstance().startTask("Udacity", request: getUserPublicInfoRequest, completionHandlerForTask: { (result, error) in
                guard let user = result?["user"], let firstname = user?["first_name"] as? String, let lastname = user?["last_name"] as? String else{
                    print("Unable to find user info in parsed result.")
                    return
                }
                NetworkClient.sharedInstance().user.firstName = firstname
                NetworkClient.sharedInstance().user.lastName = lastname
                
                // If sessionID is populated, this confirms proper commmunication with Udacity's server,
                // allow user to access.
                // I put this in here so the perform segue doesn't happen while the Facebook authentication
                // view is still on screen.
                if sessionID != ""{
                    performUIUpdatesOnMain{
                        self.performSegueWithIdentifier("segueToMap", sender: self)
                        ActivityIndicator.hide()
                    }
                } else {
                    ActivityIndicator.hide()
                    Alert.show("Unable to login", alertMessage: "No session ID provided by Udacity server. Please try again.", viewController: self)
                }

            })
            
        }
        
        
    }
    
    private func moveViewForKeyboard(notification: NSNotification){
        
        // Only run this code if either text fields are in focus
        guard emailField.isFirstResponder() || passwordField.isFirstResponder() else{
            return
        }
        
        // Get keyboard height
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        // Adjust view base on notification, but only if the view hasn't already been shifted up
        if notification.name == "UIKeyboardWillShowNotification" && !viewShiftedUp{
            view.frame.origin.y = keyboardSize.CGRectValue().height * -1
            viewShiftedUp = true
        } else if notification.name == "UIKeyboardWillHideNotification"  && viewShiftedUp{
            view.frame.origin.y = 0
            viewShiftedUp = false
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

}

