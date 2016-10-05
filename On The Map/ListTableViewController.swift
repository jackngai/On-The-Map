//
//  ListTableViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/27/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    let students = (UIApplication.sharedApplication().delegate as! AppDelegate).students
    
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
 
        tableView.delegate = self
        

    }

    @IBAction func logOut(sender: UIBarButtonItem) {
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
        
        dismissViewControllerAnimated(true, completion: nil)
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
