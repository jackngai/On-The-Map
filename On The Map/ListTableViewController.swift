//
//  ListTableViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/27/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // MARK: Properties
    // Make a copy of students information (to shorten the call in tableview methods
    // from NetworkClient.sharedInstance().students[indexPath.row] to students[indexPath.row]
    // The downside is extra memory allocation and have to clear both properties when 
    // refreshing from server
    var students = NetworkClient.sharedInstance().students
    
    // MARK: View lifecycle methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
    }
    
    
    
    // MARK: Actions
    
    @IBAction func addPin(sender: UIBarButtonItem) {
        
        NetworkClient.sharedInstance().checkForExistingPin("listToLocate", viewController: self)
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        
        // Remove data from both arrays
        NetworkClient.sharedInstance().students.removeAll(keepCapacity: false)
        students.removeAll()
        
        // Repopulate students array as a completion handler process
        // then reload the data
        NetworkClient.sharedInstance().getStudentsLocation{
            self.students = NetworkClient.sharedInstance().students
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        NetworkClient.sharedInstance().deleteSessionAndLogout{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return students.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinCell")!
        
        let student = students[indexPath.row]
        
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.detailTextLabel?.text = student.createdAt // This will show the user the sort order
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = students[indexPath.row]
 
         let app = UIApplication.sharedApplication()
        
        // Don't try to open the link if it is not a URL
         guard let url = NSURL(string: student.mediaURL) else {
         print("mediaURL is not a URL")
         return
         }
         
         app.openURL(url)
 
    }
 
}
