//
//  InstagramGlobals.swift
//  SocialMaxx
//
//  Created by bill donner on 1/6/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import Foundation

// MARK: - global storage
final class Globals {
    
    
    class var shared: Globals {
        struct Singleton {
            static let sharedAppConfiguration = Globals()
        }
        return Singleton.sharedAppConfiguration
    }
    // heavyhanded here - these are presumably loaded by the mainline whenever the user logs on
    
    // calls since startup
    var igApiCallCount = 0
    // dataset associated with original logged on user
    var igLoggedOnPersonData: OU? // nil till filled
    // ID credentials of original logged on user
    var igLoggedOnUserID : String!
    var igAccessToken : String!
    
    var showPrompts = true
    let dateFormatter = NSDateFormatter() // expensive
    
    

}