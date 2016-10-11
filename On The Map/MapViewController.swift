//
//  MapViewController.swift
//  On The Map
//
//  Created by Jack Ngai on 9/24/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit
import MapKit

/**
 * This view controller demonstrates the objects involved in displaying pins on a map.
 *
 * The map is a MKMapView.
 * The pins are represented by MKPointAnnotation instances.
 *
 * The view controller conforms to the MKMapViewDelegate so that it can receive a method
 * invocation when a pin annotation is tapped. It accomplishes this using two delegate
 * methods: one to put a small "info" button on the right side of each pin, and one to
 * respond when the "info" button is tapped.
 */

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Test code 
        
        //Will this reload the map after adding a new pin?
        mapView.reloadInputViews()
        
        // end test code
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        let students = appDelegate.students
        
        
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        for student in students {
            
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
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
        mapView.delegate = self
        
        // After the map is displayed, check if user posted any pins by using 
        // https://parse.udacity.com/parse/classes/StudentLocation?where={"uniqueKey":"1234"}
        // Save the ObjectID from response to the user.objectId field

        
        var parameters = [String:AnyObject]()
        
        let dictionary = ["uniqueKey":NetworkClient.sharedInstance().user.uniqueKey]
        
        parameters[Constants.Parse.ParameterKeys.Where] = dictionary as AnyObject
        
        let getObjectIDRequest = NetworkClient.sharedInstance().parseGet(parameters)
        
        NetworkClient.sharedInstance().startTask("Parse", request: getObjectIDRequest) { (result, error) in
            
            let dictionaries = result["results"] as! [[String:AnyObject]]
            
            let lastEntry = dictionaries[dictionaries.endIndex - 1]
            
            NetworkClient.sharedInstance().user.objectID = lastEntry["objectId"] as! String
        }
        /*
        // MARK: Old code
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22" + NetworkClient.sharedInstance().user.uniqueKey + "%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            
 
            guard error == nil else {
                print("Received error from dataTaskWithRequest")
                guard let error = error else {
                    print("Unable to safely unwrap NSERROR object")
                    return
                }
                if error.code == -1009{
                    dispatch_async(dispatch_get_main_queue()){
                        self.showAlert(error.domain, alertMessage: error.localizedDescription)
                    }
                }
                return
            }
            
            guard let data = data else{
                self.showAlert("Error", alertMessage: "There was an error retrieving student data.")
                return
            }
            
            var parsedResult:AnyObject!
            do{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Unable process JSON into foundation object")
            }
            
            let dictionaries = parsedResult["results"] as! [[String:AnyObject]]
            
            let lastEntry = dictionaries[dictionaries.endIndex - 1]
            
            appDelegate.user.objectID = lastEntry["objectId"] as! String
            
//            for dictionary in dictionaries{
//                let student = StudentInformation(dictionary: dictionary)
//                self.students.append(student)
//                
//                // MARK: Test Code
//                //print(student.firstName)
//                
//                // end test code
//                
//            }

             
 
            
            
        }
        task.resume()
        */
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
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