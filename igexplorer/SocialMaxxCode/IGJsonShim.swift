//
//  IGJson.swift
//  PhotoBrowser
//
//  Created by bill donner on 2/5/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

// All JSON dependencies are isolated in this module
// eventually SwiftyJSON can be eliminated in favor of our own code now that swift2.2 is here

import Foundation

import SwiftyJSON


struct IGJSON {
    
    static func parseIgJSONIgPeople(jsonObject:AnyObject,f1:ParseIgJSONIgPeopleFunc ) {
        let json = JSON(jsonObject)
        if (json["meta"]["code"].intValue  == 200) {
            let url = json["pagination"]["next_url"].URL
            if let resData = json["data"].arrayObject as? BunchOfIGPeople {
                f1(url,resData)
            }
        }
    }
  
    
    static func parseIgJSONIgMedia(jsonObject:AnyObject,f1:ParseIgJSONIgMediaFunc ) {
        let json = JSON(jsonObject)
        if (json["meta"]["code"].intValue  == 200) {
            let url = json["pagination"]["next_url"].URL
            if let resData = json["data"].arrayObject as? BunchOfIGMedia {
                f1(url,resData)
            }
        }
    }
    static func parseIgJSONOAuth(jsonObject:AnyObject,f1:ParseIgJSONOAuthFunc ) {
        let json = JSON(jsonObject)
        
        if let accessToken = json["access_token"].string,
            userID = json["user"]["id"].string {
                f1(accessToken,userID)
        }
        
    }
    static func parseIgJSONPicsStandard(jsonObject:AnyObject,f1:ParseIgJSONPicsStandardFunc ) {
        let json = JSON(jsonObject)
        if (json["meta"]["code"].intValue  == 200) {
            let url = json["pagination"]["next_url"].URL
            
            let photoInfos = json["data"].arrayValue
                .filter {
                    $0["type"].stringValue == "image"
                }.map({
                    PhotoInfo(sourceImageURL: $0["images"]["standard_resolution"]["url"].URL!)
                })
            f1(url,photoInfos)
        }
    }
    
    static func parseIgJSONDict(jsonObject:AnyObject,f1:ParseIgJSONDictFunc ) {
        let json = JSON(jsonObject)
        let cd =  json["meta"]["code"].intValue
       
        if let data = json["data"].dictionaryObject {
        f1(cd,data)
        }
    }
}
