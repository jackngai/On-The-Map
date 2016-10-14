//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/23/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    private let textFieldDelgate = TextFieldDelegate()
    
    private var viewShiftedUp = false
    
    private var fbToken:String!
    
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
        // Do any additional setup after loading the view, typically from a nib.
        self.tapScreenToHideKeyboard()
        
        fbLoginButton.delegate = self
    
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop receiving notification for showing/hiding keyboard
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        ActivityIndicator.show(loadingText: "Authenticating using Facebook")
//        if let token = FBSDKAccessToken.currentAccessToken().tokenString{
//            fbToken = token
//            
//        } else {
//            print("No token received from Facebook")
//        }
        
        guard let token = FBSDKAccessToken.currentAccessToken(), let tokenString = token.tokenString else{
            ActivityIndicator.hide()
            Alert.show("Unable to login with Facebook", alertMessage: "Did not receive access token from Facebook. Might be a network error or a FB credentials error. Please try again.")
            print("No token received from Facebook")
            return
        }
        
        fbToken = tokenString
        
        completeLogin()
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    @IBAction func tappedLoginButton(sender: UIButton) {
        
//        guard checkFields() else {
//            print("Invalid or missing info in Email/Password fields")
//            return
//        }
        //authActivityIndicator.hidden = false
//        performUIUpdatesOnMain { 
//            self.authActivityIndicator.startAnimating()
//
//        }
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        ActivityIndicator.show(loadingText: "Authenticating Credentials")
        completeLogin()
 
        
        //Skipping login authentication as that works
        
        
        //Go straight to map, delete this in final version
        //performSegueWithIdentifier("segueToMap", sender: self)
 
    }

    private func moveViewForKeyboard(notification: NSNotification){
        
        // Only run this code if user is editing the bottom text field
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
    
    private func checkFields()->Bool{
        guard let email = emailField.text where email.containsString("@") && email.containsString(".") else {
            Alert.show("Invalid Email", alertMessage: "Please enter a valid email address")
            return false
        }
        guard passwordField.text != "" else {
            Alert.show("Invalid Password", alertMessage: "Password is missing")
            return false
        }

        return true
    }
    
    private func completeLogin(){
        
        // MARK: Auth with Udacity POST API
        
        
        var authenticationRequest:NSMutableURLRequest!
        
        if let username = emailField.text, let password = passwordField.text where username != "" && password != ""{
            authenticationRequest = NetworkClient.sharedInstance().udacityPOST(username, password: password)
        } else if let fbToken = fbToken{
            authenticationRequest = NetworkClient.sharedInstance().udacityPOST(fbToken: fbToken)
        } else {
            print("Username/password field missing or failed to retrieve Facebook access token.")
            return
        }
        
        //let authenticationRequest = NetworkClient.sharedInstance().udacityPOST(username, password: password)
        
        NetworkClient.sharedInstance().startTask("Udacity", request: authenticationRequest) { (result, error) in
            
            // Unwrap and look for account key (User Unique Key)
            guard let accountInfo = result["account"], let optionalKey = accountInfo?["key"], let key = optionalKey as? String else {
                print("Unable to retrieve key from parsed result.")
                return
            }
            
            NetworkClient.sharedInstance().user.uniqueKey = key
            
            guard let sessionInfo = result["session"], let optionalSessionID = sessionInfo?["id"], let sessionID = optionalSessionID as? String else{
                print("Unable to retrieve session ID from parsed result.")
                return
            }
            
            print(sessionID)
            
            print("Error is: \(error)")
            
            let getUserPublicInfoRequest = NetworkClient.sharedInstance().udacityGET()
            
            NetworkClient.sharedInstance().startTask("Udacity", request: getUserPublicInfoRequest, completionHandlerForTask: { (result, error) in
                guard let user = result?["user"], let firstname = user?["first_name"] as? String, let lastname = user?["last_name"] as? String else{
                    print("Unable to find user info in parsed result.")
                    return
                }
                NetworkClient.sharedInstance().user.firstName = firstname
                NetworkClient.sharedInstance().user.lastName = lastname
            })
            
            performUIUpdatesOnMain{
                
                self.performSegueWithIdentifier("segueToMap", sender: self)
                ActivityIndicator.hide()
            }
            
        }
        
        /*
        
        // MARK: Old code
    
        let parameters = [String:AnyObject]()
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(emailField.text!)\", \"password\": \"\(passwordField.text!)\"}}"
        
        
        
        NetworkClient.sharedInstance().taskForPOSTMethod(Constants.Udacity.Methods.sessionMethod, parameters: parameters, jsonBody: jsonBody, scheme: Constants.Udacity.ApiScheme, host: Constants.Udacity.ApiHost, path: Constants.Udacity.Methods.sessionMethod) { (result, error) in
            //print(result)
            
            guard let accountInfo = result["account"], let optionalKey = accountInfo?["key"], let key = optionalKey as? String else {
                print("Unable to retrieve key from parsed result.")
                return
            }
            
            NetworkClient.sharedInstance().user.uniqueKey = key
            
            print("Error is: \(error)")
            
            
            
            
            // MARK: old code
            
            //(UIApplication.sharedApplication().delegate as! AppDelegate).user.uniqueKey = key
            
            // end old code
            
            NetworkClient.sharedInstance().user.uniqueKey = key
            
            // MARK: Test Code
            
            //NetworkClient.sharedInstance().sessionID = key
            
            // end test code
            
            
            print("Error is: \(error)")
            
            
            // MARK: Get user public data with Udacity GET API
            
            NetworkClient.sharedInstance().taskForGETMethod(Constants.Udacity.Methods.userinfoMethod, parameters: parameters, scheme: Constants.Udacity.ApiScheme, host: Constants.Udacity.ApiHost,  path: Constants.Udacity.Methods.sessionMethod, completionHandlerForGET: { (result, error) in
                
                guard let user = result["user"], let firstname = user?["first_name"] as? String, let lastname = user?["last_name"] as? String else{
                    print("Unable to find user info in parsed result.")
                    return
                }
                
                NetworkClient.sharedInstance().user.firstName = firstname
                NetworkClient.sharedInstance().user.lastName = lastname
                
            })
            
            performUIUpdatesOnMain{
                self.performSegueWithIdentifier("segueToMap", sender: self)
            }
            
        
        }
 
        */
        
        /*
        
        // MARK: Old code - Auth with Udacity POST API
        
        let request = NSMutableURLRequest(URL: NetworkClient.sharedInstance().networkURLFromParameters(parameters, withPathExtension: Constants.Udacity.Methods.sessionMethod, scheme: Constants.Udacity.ApiScheme, host: Constants.Udacity.ApiHost, path: Constants.Udacity.ApiPath))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailField.text!)\", \"password\": \"\(passwordField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // MARK: Test Code - Decode HTTPBody to make sure everything looks good
        let body:AnyObject!
        
        do{
            body = try NSJSONSerialization.JSONObjectWithData(request.HTTPBody!, options: .AllowFragments)
        } catch {
            print("Unable to parse HTTPBody to foundation object")
            return
        }
        
        print(body)
        
        // End test code
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            data, response, error in
            guard error == nil else {
                print("Received error from dataTaskWithRequest")
                guard let error = error else {
                    print("Unable to safely unwrap NSERROR object")
                    return
                }
                if error.code == -1009{
                    dispatch_async(dispatch_get_main_queue()){
                        self.showAlert(error.domain, alertMessage: error.localizedDescription)
                    }
                }
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 300 else {
                if (response as? NSHTTPURLResponse)?.statusCode == 403{
                    dispatch_async(dispatch_get_main_queue(), {
                        // MARK: Test code
                        //                        let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
                        //                        print(NSString(data: newData!, encoding: NSUTF8StringEncoding)!)
                        
                        //end test code
                        self.showAlert("Invalid Credentials", alertMessage: "Please check your username or password")
                        
                    })
                }
                print((response as? NSHTTPURLResponse)?.statusCode)
                return
                
            }
            

            
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            // MARK: Test code
            
            //print(NSString(data: newData!, encoding: NSUTF8StringEncoding)!)
            
            //end test code
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON")
            }
            
            guard let accountInfo = parsedResult?["account"], let optionalKey = accountInfo?["key"], let key = optionalKey as? String else {
                print("Unable to retrieve key from parsed result.")
                return
            }
            
            // MARK: Test code
            // print(key)
            // end test code
            
            // MARK: old code
            
            //(UIApplication.sharedApplication().delegate as! AppDelegate).user.uniqueKey = key
            
            // end old code
            
            NetworkClient.sharedInstance().user.uniqueKey = key
            

            
            // MARK: Get user public data using user id (Key)
            
            // MARK: Test code
            // print("http://www.udacity.com/api/users/" + key)
            // end test code

            
            // MARK: Old code - Get user public data with Udacity GET API
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/" + key)!)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) {
                data, response, error in
                if error != nil { // Handle error...
                    return
                }
                
                let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                // MARK: Test code
                
                // print(NSString(data: newData!, encoding: NSUTF8StringEncoding)!)
                
                //end test code
                
                var parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
                } catch {
                    print("Could not parse the data as JSON")
                }
                
                guard let user = parsedResult?["user"], let firstname = user?["first_name"] as? String, let lastname = user?["last_name"] as? String else{
                    print("Unable to find user info in parsed result.")
                    return
                }
                // MARK: Test code
                
                // print(lastname + ", " + firstname)
                
                //end test code
                
                // MARK: Old code
                /*
                
                (UIApplication.sharedApplication().delegate as! AppDelegate).user.firstName = firstname
                (UIApplication.sharedApplication().delegate as! AppDelegate).user.lastName = lastname
                */
                
                NetworkClient.sharedInstance().user.firstName = firstname
                NetworkClient.sharedInstance().user.lastName = lastname

                
            }
            task.resume()
            
            
            
            performUIUpdatesOnMain({
                self.performSegueWithIdentifier("segueToMap", sender: self)
            })
            
            
        }
        task.resume()
        

        
        return
    */
        
    }

}

