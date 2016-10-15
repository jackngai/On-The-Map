//
//  NetworkClient.swift
//  On The Map
//
//  Created by Jack Ngai on 10/1/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import UIKit

// MARK: - NetworkClient: NSObject

class NetworkClient : UIViewController {
    
    
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // MARK: Properties
    
    var user = StudentInformation()
    
    var students = [StudentInformation]()
    
    
    // MARK: GET
    
    func udacityDelete()->NSMutableURLRequest{
        let url = buildURL(Constants.Udacity.ApiScheme, host: Constants.Udacity.ApiHost, path: Constants.Udacity.Methods.sessionMethod)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        return request
        
        
    }
    
    func parsePutOrPost (HTTPMethod: String, link: String, latitude: Double, longitude: Double)->NSMutableURLRequest {
        
        var url=NSURL()
        
        switch HTTPMethod {
        case "PUT":
            url = buildURL(Constants.Parse.ApiScheme, host: Constants.Parse.ApiHost, path: Constants.Parse.ApiPutPath, withPathExtension: user.objectID)
        case "POST":
            url = buildURL(Constants.Parse.ApiScheme, host: Constants.Parse.ApiHost, path: Constants.Parse.ApiPath)
        default:
            print("Unrecognized HTTPMethod. Defaulting to POST")
            url = buildURL(Constants.Parse.ApiScheme, host: Constants.Parse.ApiHost, path: Constants.Parse.ApiPath)
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = HTTPMethod
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(user.uniqueKey)\", \"firstName\": \"\(user.firstName)\", \"lastName\": \"\(user.lastName)\",\"mapString\": \"\(user.mapString)\", \"mediaURL\": \"\(link)\" ,\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)

        return request
        
    }
    
    func parseGet(parameters: [String:AnyObject])->NSMutableURLRequest{
        
        let url = buildURL(Constants.Parse.ApiScheme, host: Constants.Parse.ApiHost, path: Constants.Parse.ApiPath, parameters: parameters)
        let request = NSMutableURLRequest(URL: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        return request
    }
    
    func udacityGET()->NSMutableURLRequest{
        
        let url = buildURL(Constants.Udacity.ApiScheme, host: Constants.Udacity.ApiHost, path: Constants.Udacity.Methods.userinfoMethod, withPathExtension: user.uniqueKey)

        return NSMutableURLRequest(URL: url)
        
    }
    
    func udacityPOST(username: String = "", password: String = "", fbToken: String = "")->NSMutableURLRequest{
        
        var jsonBody:String!
        
        if username != "" && password != ""{
            jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        } else{
            jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(fbToken)\"}}"
        }
        
        let url = buildURL(Constants.Udacity.ApiScheme, host: Constants.Udacity.ApiHost, path: Constants.Udacity.Methods.sessionMethod)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
               
        return request
        
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    func startTask(clientAPI: String, request: NSMutableURLRequest, completionHandlerForTask: (result:AnyObject!, error: NSError?)->Void)->NSURLSessionDataTask{
        
        let task = session.dataTaskWithRequest(request) {
            data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                if let error = error{
                    
                    // Display error as an alert on screen if the issue is related to internet connection
                    if error.code == -1009{
                        performUIUpdatesOnMain({
                            Alert.show(error.domain, alertMessage: error.localizedDescription)
                        })
                    }
                }
                return
            }
            
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Status code: \((response as? NSHTTPURLResponse)?.statusCode))")
                
                // Display status code as an alert on screen if the issue is invalid credentials
                if (response as? NSHTTPURLResponse)?.statusCode == 403{
                    performUIUpdatesOnMain({ 
                        Alert.show("Invalid Credentials", alertMessage: "Please check the username and/or password.")
                    })
                }
                
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            //If this is for Udacity's API, use the data set that removed the first 5 characters
            if clientAPI == "Udacity" {
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForTask)
            }
            else if clientAPI == "Parse" {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForTask)
            } else {
                print("Unrecognized client API, no data will be converted.")
            }
        
            
        }
        task.resume()
        
        return task
    }
    
    func buildURL(scheme: String, host: String, path: String, withPathExtension: String? = nil, parameters: [String:AnyObject]? = nil)->NSURL{
        
        let components = NSURLComponents()
        
        components.scheme = scheme
        components.host = host
        
        if let withPathExtension = withPathExtension{
            components.path = path + withPathExtension
        } else {
            components.path = path
        }
        
//        guard let parameters = parameters else {
//            if host.containsString("parse"){
//                print("Parse API with no parameters, potential issue")
//            }
//            if let url = components.URL {
//                print(url)
//                return url
//            }
//
//        }
        
        if let parameters = parameters{
            components.queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        guard let url = components.URL else {
            print("buildURLfailed")
            return NSURL(string: "")!
        }
        
        // MARK: Test code
        print(url)
        // end test code
        
        return url

    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> NetworkClient {
        struct Singleton {
            static var sharedInstance = NetworkClient()
        }
        return Singleton.sharedInstance
    }
    
}