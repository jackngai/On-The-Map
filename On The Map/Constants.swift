//
//  Constants.swift
//  On The Map
//
//  Created by Jack Ngai on 9/30/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import Foundation

struct Constants{
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        //static let SessionID = "session_id"
        //static let RequestToken = "request_token"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        //static let StatusMessage = "status_message"
        //static let StatusCode = "status_code"
        
        // MARK: Authorization
        //static let RequestToken = "request_token"
        //static let SessionID = "session_id"
        
        // MARK: Account
        //static let UserID = "id"
        
    }

    
    struct Parse{
        static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIkey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: Parse URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes/StudentLocation"
        static let ApiPutPath = "/parse/classes/StudentLocation/"
        
        struct ParameterKeys {
            static let limit = "limit"
            static let skip = "skip"
            static let order = "order"
            static let Where = "where" // Can't use lower case because where is a swift keyword
        }
    }
    
    struct Udacity{
        struct Methods{
            static let sessionMethod = "/api/session"
            static let userinfoMethod = "/api/users/"
        }
        
        // MARK: Udacity URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        
        struct ParameterKeys {
            static let udacity = "udacity"
            static let user = "username"
            static let pw = "password"
        }
        

    }
    
}
