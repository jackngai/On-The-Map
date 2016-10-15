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
    
    // MARK: Outlets
    @IBOutlet weak var locationTextField: UITextField!
    
    // MARK: Properties
    var annotation:MKAnnotation!
    var searchRequest:MKLocalSearchRequest!
    var search:MKLocalSearch!
    var searchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    
    // MARK: View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapScreenToHideKeyboard()
    }

    
    // MARK: Override method
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        let controller = segue.destinationViewController as! MapAndPinViewController
        
        // Pass searchResponse to MapAndPinViewController so it will have the location info
        controller.searchResponse = searchResponse
    }
    
    // MARK: Actions
    @IBAction func find(sender: UIButton) {
        
        
        
        // Check to confirm location text field is not blank
        guard let location = locationTextField.text else{
            print("location field is nil")
            return
        }
        
        // Save the map string to the user's struct
        NetworkClient.sharedInstance().user.mapString = location
        
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
