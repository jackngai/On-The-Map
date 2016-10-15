//
//  MapAndPinViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/30/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit
import MapKit

class MapAndPinViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    var searchResponse:MKLocalSearchResponse!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!

    // MARK: View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tapScreenToHideKeyboard()
        
        self.pointAnnotation = MKPointAnnotation()
        self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        self.mapView.setRegion(searchResponse.boundingRegion, animated: true)
    }
    
    // MARK: Actions
    @IBAction func submit(sender: AnyObject) {
        
        guard let link = linkTextField.text where link != "" else {
            print("Link field is blank. Please type in a link.")
            return
        }
        
        // Save user's coordinates and link to the student struct
        NetworkClient.sharedInstance().user.latitude = searchResponse!.boundingRegion.center.latitude
        NetworkClient.sharedInstance().user.longitude = searchResponse!.boundingRegion.center.longitude
        NetworkClient.sharedInstance().user.mediaURL = link
        
        // If Object ID is blank, create a PUT (overwrite) request, else create a POST (add new pin) request
        var request = NSMutableURLRequest()
        if NetworkClient.sharedInstance().user.objectID != ""{
            
            request = NetworkClient.sharedInstance().parsePutOrPost("PUT", link: link, latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
            
        } else {
            
            request = NetworkClient.sharedInstance().parsePutOrPost("POST", link: link, latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
        }
        
            NetworkClient.sharedInstance().startTask("Parse", request: request, completionHandlerForTask: { (result, error) in
                
                guard error == nil else{
                    print("Received error: \(error)")
                    return
                }
                
                guard let result = result else{
                    print("result is nil")
                    return
                }
   
                if NetworkClient.sharedInstance().user.objectID != ""{
                    print("Updated successfully on: \(result["updatedAt"])")
                } else {
                    print("New pin added on: \(result["createdAt"])")
                }
                
            })
    
        
        

    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
