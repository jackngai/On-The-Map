//
//  StudentStruct.swift
//  On The Map
//
//  Created by Jack Ngai on 9/28/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//


import UIKit

struct StudentInformation {
    var createdAt:String
    var firstName:String
    var lastName:String
    var latitude:Double
    var longitude:Double
    var mapString:String
    var mediaURL:String
    var objectID:String
    var uniqueKey:String
    var updatedAt:String
    
    init(dictionary:[String:AnyObject]){
        
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? Double ?? 0.0
        self.longitude = dictionary["longitude"] as? Double ?? 0.0
        self.mapString = dictionary["mapString"] as? String ?? ""
        self.mediaURL = dictionary["mediaURL"] as? String ?? ""
        self.objectID = dictionary["objectID"] as? String ?? ""
        self.uniqueKey = dictionary["uniqueKey"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
        
    }
    
    init(){
        self.createdAt = ""
        self.firstName = ""
        self.lastName = ""
        self.latitude = 0.0
        self.longitude = 0.0
        self.mapString = ""
        self.mediaURL = ""
        self.objectID = ""
        self.uniqueKey = ""
        self.updatedAt = ""
    }
    
    
}

