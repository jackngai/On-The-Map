//
//  ListTableViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/27/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    let students = NetworkClient.sharedInstance().students
    
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.delegate = self
        

    }

    @IBAction func logOut(sender: UIBarButtonItem) {
    
        
        NetworkClient.sharedInstance().deleteSessionAndLogout{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
//        ActivityIndicator.show()
//        
//        let deleteCookieRequest = NetworkClient.sharedInstance().udacityDelete()
//        
//        NetworkClient.sharedInstance().startTask("Udacity", request: deleteCookieRequest) { (result, error) in
//            guard let session = result["session"] as? [String:String], let sessionID = session["id"] else {
//                print("Unable to retrieve session ID")
//                return
//            }
//            guard error == nil else {
//                print(error)
//                return
//            }
//            if sessionID == ""{
//                performUIUpdatesOnMain({
//                    ActivityIndicator.hide()
//                    Alert.show("Logout Error", alertMessage: "Unable to delete session ID. Please try again.")
//                })
//            } else {
//                performUIUpdatesOnMain({
//                    ActivityIndicator.hide()
//                    self.dismissViewControllerAnimated(true, completion: nil)
//                })
//            }
//        }
        
        
        
        
        //let result = result,
        //dismissViewControllerAnimated(true, completion: nil)
        
        /*
        // MARK: Old code
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data?.subdataWithRange(NSMakeRange(5, data!.length - 5))
            print(NSString(data: newData!, encoding: NSUTF8StringEncoding)!)
        }
        task.resume()
        */
        
        
    }
    


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return students.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinCell")!
        
        let student = students[indexPath.row]
        
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.detailTextLabel?.text = student.createdAt
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = students[indexPath.row]
 
         let app = UIApplication.sharedApplication()
        
         guard let url = NSURL(string: student.mediaURL) else {
         print("mediaURL is not a URL")
         return
         }
         
         app.openURL(url)
 
        
    }
 



}
