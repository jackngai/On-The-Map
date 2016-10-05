//
//  AppDelegate.swift
//  On The Map
//
//  Created by Jack Ngai on 9/23/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let helper = Helper()

    var locations = [[String:AnyObject]]()
    
    var students = [StudentInformation]()
    
    var user = StudentInformation()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                print("Received error from dataTaskWithRequest")
                guard let error = error else {
                    print("Unable to safely unwrap NSERROR object")
                    return
                }
                if error.code == -1009{
                    dispatch_async(dispatch_get_main_queue()){
                        self.helper.showAlert(error.domain, alertMessage: error.localizedDescription)
                    }
                }
                return
            }
            
            guard let data = data else{
                self.helper.showAlert("Error", alertMessage: "There was an error retrieving student data.")
                return
            }
            
            var parsedResult:AnyObject!
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Unable process JSON into foundation object")
            }
                self.locations = parsedResult["results"] as! [[String:AnyObject]]
                
                let dictionaries = parsedResult["results"] as! [[String:AnyObject]]
                
                for dictionary in dictionaries{
                    let student = StudentInformation(dictionary: dictionary)
                    self.students.append(student)
                    
                    // MARK: Test Code
                    //print(student.firstName)
                    
                    // end test code
                    
                }
            
        }
        task.resume()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

