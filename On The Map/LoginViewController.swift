//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/23/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func tappedLoginButton(sender: UIButton) {
        getSession()
    }
    
    private func getSession(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/JSON", forHTTPHeaderField: "Accept")
        request.addValue("application/JSON", forHTTPHeaderField: "Content-Type")
        
        // My code to use the email and password field text
        //request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailField.text!)\", \"password\": \"\(passwordField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Copied and Paste code
        request.HTTPBody = "{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}".dataUsingEncoding(NSUTF8StringEncoding)

        // Decode HTTPBody to make sure everything looks good
        do{
            let value = try NSJSONSerialization.JSONObjectWithData(request.HTTPBody!, options: .AllowFragments)
            print(value)
        } catch {
            print("Unable to parse HTTPBody to foundation object")
            return
        }
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            data, response, error in
            guard error == nil else {
                print("Received error from dataTaskWithRequest")
                print(error)
                return
            }
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: newData!, encoding: NSUTF8StringEncoding)!)
            
        }
        task.resume()
    }
    
}

