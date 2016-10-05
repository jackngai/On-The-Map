//
//  LocateViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/30/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit
import MapKit

class LocateViewController:UIViewController{
    
    @IBOutlet weak var locationTextField: UITextField!
    
    var annotation:MKAnnotation!
    var searchRequest:MKLocalSearchRequest!
    var search:MKLocalSearch!
    var searchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
                // Check if a pin exists for the current session, if it does, cancel
                let object = UIApplication.sharedApplication().delegate
                let appDelegate = object as! AppDelegate
        //let user = appDelegate.user
        //      let students = appDelegate.students
        
                for student in (UIApplication.sharedApplication().delegate as! AppDelegate).students{

                    if student.uniqueKey == appDelegate.user.uniqueKey {
                        let alertController = UIAlertController(title: nil, message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .Alert)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action:UIAlertAction) in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
        
                        alertController.addAction(UIAlertAction(title: "Overwrite", style: .Default, handler: nil))
                        alertController.addAction(cancelAction)
        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let controller = segue.destinationViewController as! MapAndPinViewController
        
        controller.searchResponse = searchResponse
    }
    
    
    @IBAction func find(sender: UIButton) {
        
        // Save the map string to the user's struct
        guard let location = locationTextField.text else{
            print("location field is nil")
            return
        }
        (UIApplication.sharedApplication().delegate as! AppDelegate).user.mapString = location
        
        searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = locationTextField.text
        search = MKLocalSearch(request: searchRequest)
        search.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            guard let localSearchResponse = localSearchResponse else {
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            self.searchResponse = localSearchResponse
            self.performSegueWithIdentifier("segueToMapAndPin", sender: self)
        }
        

    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
