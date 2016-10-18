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
    let reach = Reach()

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
            Alert.show("Link field is blank", alertMessage: "Please type in a link.", viewController: self)
            print("Link field is blank. Please type in a link.")
            return
        }
        
        guard reach.connectionStatus().description != "Offline" else{
            Alert.show("Network Error", alertMessage: "Unable to communicate with server. Please try again.", viewController: self)
            return
        }
        
        
        print(reach.connectionStatus())
        
        // Save user's coordinates and link to the student struct
        NetworkClient.sharedInstance().user.latitude = searchResponse!.boundingRegion.center.latitude
        NetworkClient.sharedInstance().user.longitude = searchResponse!.boundingRegion.center.longitude
        NetworkClient.sharedInstance().user.mediaURL = link
        
        // Add entry to the students array so user don't have to wait til server
        // refresh to see their entry
        NetworkClient.sharedInstance().students.insert(NetworkClient.sharedInstance().user, atIndex: 0)
        
        // If Object ID is blank, create a PUT (overwrite) request, else create a POST (add new pin) request
        var request = NSMutableURLRequest()
        if NetworkClient.sharedInstance().user.objectID != ""{
            
            request = NetworkClient.sharedInstance().parsePutOrPost("PUT", link: link, latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
            
        } else {
            
            request = NetworkClient.sharedInstance().parsePutOrPost("POST", link: link, latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
        }
        
            NetworkClient.sharedInstance().startTask("Parse", request: request, completionHandlerForTask: { (result, error) in
                
                guard error == nil else{
                Alert.show("Error", alertMessage: "Received an error trying to update or add a location", viewController: self)
                    NetworkClient.sharedInstance().postStatusCompletion = false
                    print("Received error: \(error)")
                    return
                }
                
                guard let result = result else{
                    Alert.show("Error", alertMessage: "Did not receive any data confirming location was updated/added successfully", viewController: self)
                    print("result is nil")
                    return
                }
   
                if NetworkClient.sharedInstance().user.objectID != ""{
                    
                    guard let updatedAt = result["updatedAt"] as? String else {
                        print("Unable to downcast updatedAt field from AnyObject to String")
                        return
                    }
                    print("Updated successfully on: \(updatedAt)")
                    // The intention is to wait til this field is updated before
                    // adding user struct to the students array. But because this
                    // is happening asynchronously, the user is back in the mapView
                    // and there's no way to show the user their pin unless they
                    // keep hitting refresh. So I ended up adding the user stuct 
                    // to the students array earlier in this method.
                    NetworkClient.sharedInstance().user.updatedAt = updatedAt
                    
                } else {
                    guard let createdAt = result["createdAt"] as? String else {
                        print("Unable to downcast createdAt field from AnyObject to String")
                        return
                    }
                    print("New pin added on: \(createdAt)")
                    NetworkClient.sharedInstance().user.createdAt = createdAt
                }
                

            })
        // Add activity indicator and delay so the MapAndPinViewController is not 
        // segued out of view if there is an error with the network.
        ActivityIndicator.show(loadingText: "Adding/Updating Pin.")
        let seconds = 4.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
             self.performSegueWithIdentifier("unwindAfterAddingPin", sender: self)
            
        })
        
       

    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
