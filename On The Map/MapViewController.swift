//
//  MapViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/24/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!

    
    // MARK: Properties
    // Create an empty array of map annotations
    var annotations = [MKPointAnnotation]()
    
    // MARK: View Lifecycle methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Test code 
        
        //Will this reload the map after adding a new pin?
        mapView.reloadInputViews()
        
        // end test code
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Populate map annotations array with information from students array
        populateAnnotations()

        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
        mapView.delegate = self
        
        
        // MARK: Look for any location pins placed by the current user by using the user unique key
        // Create a empty dictionary of parameters
        var parameters = [String:AnyObject]()
        
        // Create a string version of {"uniqueKey":"1234"} where 1234 is the unique Key for the user
        let dictionaryString = "{\"uniqueKey\":\"\(NetworkClient.sharedInstance().user.uniqueKey)\"}"
        
        //let percentEncodedDictString = dictionaryString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    
        
        // Add dictionary as a value to the where key to create
        // Ex: https://parse.udacity.com/parse/classes/StudentLocation?where={"uniqueKey":"1234"}
        parameters[Constants.Parse.ParameterKeys.Where] = dictionaryString
        
        
        let getObjectIDRequest = NetworkClient.sharedInstance().parseGet(parameters)
        
        NetworkClient.sharedInstance().startTask("Parse", request: getObjectIDRequest) { (result, error) in
            
            guard error == nil else{
                print("Received this error trying to locate Object ID: \(error)")
                return
            }
            
            guard result != nil else{
                print("Received nil from server when trying to locate Object ID")
                return
            }
            
            let dictionaries = result["results"] as! [[String:AnyObject]]
            
            let lastEntry = dictionaries[dictionaries.endIndex - 1]
            
            // Save the ObjectID from response to the user.objectId field
            NetworkClient.sharedInstance().user.objectID = lastEntry["objectId"] as! String
        }
        
    }
    
    
    @IBAction func unwindAfterAddingPin(segue: UIStoryboardSegue){
        // This is the controller that MapAndPinView will unwind to after clicking "Submit"
        let button = UIBarButtonItem()
        refresh(button)
    }
    
    
    @IBAction func addPin(sender: UIBarButtonItem) {
        
        NetworkClient.sharedInstance().checkForExistingPin("mapToLocate", viewController: self)
        
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        
        NetworkClient.sharedInstance().deleteSessionAndLogout{
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        mapView.removeAnnotations(annotations)
        NetworkClient.sharedInstance().students.removeAll(keepCapacity: false)
        NetworkClient.sharedInstance().getStudentsLocation{
            self.populateAnnotations()
        }
        mapView.addAnnotations(annotations)
    }
    
    private func populateAnnotations(){
        
        // Erase existing annotations
         annotations.removeAll()
        
        for student in NetworkClient.sharedInstance().students {
            
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
    }
    
    
    private func showAlert(alertTitle: String, alertMessage: String){
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // Safely check if the subtitle field contains a URL and open if it does
        guard control == view.rightCalloutAccessoryView else {
            print("control doesn't match rightCalloutAccessoryView")
            return
        }
        let app = UIApplication.sharedApplication()
        
        guard let toOpen = view.annotation?.subtitle! else {
            print("subtitle field is nil")
            return
        }
        guard let url = NSURL(string: toOpen) else {
            print("subtitle is not a URL")
            return
        }
        
        app.openURL(url)
        
    }
    
}