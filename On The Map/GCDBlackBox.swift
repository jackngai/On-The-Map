//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Jack Ngai on 9/28/16.
//  Copyright © 2016 Jack Ngai. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates:()->Void){
    dispatch_async(dispatch_get_main_queue()) { 
        updates()
    }
}


