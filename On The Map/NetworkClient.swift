//
//  NetworkClient.swift
//  On The Map
//
//  Created by Jack Ngai on 10/1/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import Foundation

// MARK: - NetworkClient: NSObject

class NetworkClient : NSObject {
    
    
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // MARK: Properties
    
    var user = StudentInformation()
    
    
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
            url = buildURL(Constants.Parse.ApiScheme, host: Constants.Parse.ApiHost, path: Constants.Parse.ApiPath, withPathExtension: user.objectID)
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
    
    func udacityPOST(username: String, password: String)->NSMutableURLRequest{
        
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
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
                            Helper.showAlert(error.domain, alertMessage: error.localizedDescription)
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
                        Helper.showAlert("Invalid Credentials", alertMessage: "Please check the username and/or password.")
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
        
        
        guard let url = components.URL else {
            return NSURL(string: "buildURLfailed")!
        }
        
        guard let parameters = parameters else {
            print("No parameters provided")
            return url
        }
        
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
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
    
    //---------------------------------------------------------------------------------------------------
/*
    func taskForGETMethod<Scheme, Host, Path>(method: String, parameters: [String:AnyObject], scheme: Scheme, host: Host, path: Path, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
//        if (host as! String).containsString("parse"){
//            parametersWithApiKey[Constants.ParameterKeys.ApiKey] = Constants.Parse.APIkey
//        }
        
        /* 2/3. Build the URL, Configure the request */
        
        var request = NSMutableURLRequest(URL: networkURLFromParameters(parametersWithApiKey, withPathExtension: method, user: user.uniqueKey, scheme: scheme, host: host, path: path))
        
        // MARK: Modify request if this is for Parse API
        
        if (host as! String).containsString("parse"){
            let dictionary = ["uniqueKey":user.uniqueKey]
            
            parametersWithApiKey[Constants.Parse.ParameterKeys.Where] = dictionary
             request = NSMutableURLRequest(URL: networkURLFromParameters(parametersWithApiKey, withPathExtension: method, scheme: scheme, host: host, path: path))
            request.addValue(Constants.Parse.appID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.Parse.APIkey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Status code: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            // If this is for Udacity's API, use the data set that removed the first 5 characters
            if (host as! String).containsString("www") {
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
            }
            else{
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }

    // MARK: POST
    
    func taskForPOSTMethod<Scheme, Host, Path>(method: String, parameters: [String:AnyObject], jsonBody: String, scheme: Scheme, host: Host, path: Path, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        if (host as! String).containsString("parse"){
            parametersWithApiKey[Constants.ParameterKeys.ApiKey] = Constants.Parse.APIkey
        }

        /* 2/3. Build the URL, Configure the request */
        
        // MARK: Remember to adjust scheme, host, path so they are not fixed
        let request = NSMutableURLRequest(URL: networkURLFromParameters(parametersWithApiKey, withPathExtension: method, scheme: scheme, host: host, path: path))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Test Code */
        do{
            let value = try NSJSONSerialization.JSONObjectWithData(request.HTTPBody!, options: .AllowFragments)
            print(value)
        } catch {
            print("Unable to parse HTTPBody to foundation object")
        }
        /* End Test Code */
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Status code: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            // If this is for Udacity's API, use the data set that removed the first 5 characters
            if (host as! String).containsString("www") {
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
            }
            else{
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
       
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    

    
    // create a URL from parameters
    func networkURLFromParameters<Scheme, Host, Path>(parameters: [String:AnyObject], withPathExtension: String? = nil, user: String? = nil, scheme: Scheme, host: Host, path: Path) -> NSURL {
        
    
        let components = NSURLComponents()
        //var currentSource:
        
            components.scheme = scheme as? String
            components.host = host as? String
            components.path = (path as! String) + (withPathExtension ?? "") + (user ?? "")

        
        //let currentSource = source as! Constants

//        components.scheme = source.ApiScheme
//        components.host = Constants.ApiHost
//        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    */

}