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
    
    @IBOutlet weak var linkTextField: UITextField!

    @IBOutlet weak var mapView: MKMapView!
    
    //var user = (UIApplication.sharedApplication().delegate as! AppDelegate).user
    
    var searchResponse:MKLocalSearchResponse!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.pointAnnotation = MKPointAnnotation()
        //self.pointAnnotation.title = searchBar.text
        self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
        
        
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
        self.mapView.centerCoordinate = self.pointAnnotation.coordinate
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        self.mapView.setRegion(searchResponse.boundingRegion, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        guard let link = linkTextField.text where link != "" else {
            print("Link field is blank. Please type in a link.")
            return
        }
        
        NetworkClient.sharedInstance().user.latitude = searchResponse!.boundingRegion.center.latitude
        NetworkClient.sharedInstance().user.longitude = searchResponse!.boundingRegion.center.longitude
        NetworkClient.sharedInstance().user.mediaURL = link
        
        // Add new entry to the array
        (UIApplication.sharedApplication().delegate as! AppDelegate).students[0] = NetworkClient.sharedInstance().user
        
        if NetworkClient.sharedInstance().user.objectID != ""{
            
            let overwriteRequest = NetworkClient.sharedInstance().parsePutOrPost("PUT", link: link, latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
            
            NetworkClient.sharedInstance().startTask("Parse", request: overwriteRequest, completionHandlerForTask: { (result, error) in
                guard let result = result else{
                    print("result is nil")
                    return
                }
                guard let error = error else{
                    print("error is nil")
                    return
                }
                print(result)
                print(error)
            })
            

            
            /*
            // MARK: Old code
            
            let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/" + user.objectID
            let url = NSURL(string: urlString)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "PUT"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = "{\"uniqueKey\": \"\(user.uniqueKey)\", \"firstName\": \"\(user.firstName)\", \"lastName\": \"\(user.lastName)\",\"mapString\": \"\(user.mapString)\", \"mediaURL\": \"\(link)\" ,\"latitude\": \(searchResponse!.boundingRegion.center.latitude), \"longitude\": \(searchResponse!.boundingRegion.center.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
    
            
            user.latitude = searchResponse!.boundingRegion.center.latitude
            user.longitude = searchResponse!.boundingRegion.center.longitude
            user.mediaURL = link
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                // MARK: Test code
                
                // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                // print(error)
                
                //end test code
                
                
            }
            task.resume()
            
            // MARK: Test code
            
            //print(user)
            //print((UIApplication.sharedApplication().delegate as! AppDelegate).students)
            
            //end test code
            
            //(UIApplication.sharedApplication().delegate as! AppDelegate).students.insert(user, atIndex: 0)
            (UIApplication.sharedApplication().delegate as! AppDelegate).students[0] = user
 
        */
            
        } else {
            
            
            let addNewLocationRequest = NetworkClient.sharedInstance().parsePutOrPost("POST", link: link, latitude: searchResponse!.boundingRegion.center.latitude, longitude: searchResponse!.boundingRegion.center.longitude)
            
            NetworkClient.sharedInstance().startTask("Parse", request: addNewLocationRequest, completionHandlerForTask: { (result, error) in
                guard let result = result else{
                    print("result is nil")
                    return
                }
                guard let error = error else{
                    print("error is nil")
                    return
                }
                print(result)
                print(error)
            })
            
            /*
            // MARK: Old code
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
            request.HTTPMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            request.HTTPBody = "{\"uniqueKey\": \"\(user.uniqueKey)\", \"firstName\": \"\(user.firstName)\", \"lastName\": \"\(user.lastName)\",\"mapString\": \"\(user.mapString)\", \"mediaURL\": \"\(link)\" ,\"latitude\": \(searchResponse!.boundingRegion.center.latitude), \"longitude\": \(searchResponse!.boundingRegion.center.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
            
            
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                
                // MARK: Test code
                
                // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                // print(error)
                
                //end test code
                
            }
            task.resume()
 
 
            
            // MARK: Test code
            
            //print(user)
            //print((UIApplication.sharedApplication().delegate as! AppDelegate).students)
            
            //end test code

            */
        }
        
        performSegueWithIdentifier("unwind", sender: self)
        

    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
