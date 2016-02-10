//
//  IGNetOps.swift
//  PhotoBrowser
//
//  Created by bill donner on 2/7/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import UIKit

typealias NetCompletionFunc = (status: Int, object: AnyObject?) -> ()
typealias NetImgCompletionFunc = (status: Int, object: UIImage?) -> ()

struct IGNetOps {
    static var session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()) // just one session
    
    static func dataTask(request: NSMutableURLRequest, method: String, completion: NetCompletionFunc) {
        request.HTTPMethod = method
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if let response = response as? NSHTTPURLResponse {
                let responsecode = response.statusCode
                
                print("- dataTask \(responsecode) \(method) \(request.URL!.path!)")
                if 200...299 ~= response.statusCode {
                    if let data = data {
                        let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                        completion(status: responsecode, object: json)
                    }
                } else {
                    completion(status: responsecode, object: nil)
                }
            }
            }.resume()
    }
    
    
    static func imageTask(request: NSMutableURLRequest, method: String, completion:NetImgCompletionFunc) {
        request.HTTPMethod = method
        
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if
                let response = response as? NSHTTPURLResponse {
                    let responsecode = response.statusCode
                    
                    print("- imageTask \(responsecode) \(method) \(request.URL!.path!)")
                    if 200...299 ~= response.statusCode {
                        if let data = data, let image = UIImage(data:data){
                            completion(status: responsecode, object: image)
                        }
                    } else {
                        completion(status:responsecode, object: nil)
                    }
                    
            }
            }.resume()
    }
    
    static func post(request: NSMutableURLRequest, completion:NetCompletionFunc) {
        IGNetOps.dataTask(request, method: "POST", completion: completion)
    }
    
    static func put(request: NSMutableURLRequest, completion:NetCompletionFunc) {
        IGNetOps.dataTask(request, method: "PUT", completion: completion)
    }
    
    static func get(request: NSMutableURLRequest, completion:NetCompletionFunc) {
        IGNetOps.dataTask(request, method: "GET", completion: completion)
    }
    static func getImg(request: NSMutableURLRequest, completion:NetImgCompletionFunc) {
        IGNetOps.imageTask(request, method: "GET", completion: completion)
    }
    
    
    
    
    static  func nwGetImage(nsurl:NSURL ,completion:NetImgCompletionFunc )
        throws -> NSMutableURLRequest  {
            let req = NSMutableURLRequest(URL: nsurl)
            
            IGOps.nwEncode(req, parameters: [:])
            IGNetOps.getImg(req) {statuscode , image in
                if image == nil {
                    print("Api Failure \(statuscode) in nwGetImage \(nsurl)")
                }
                else {
                    completion(status:statuscode,object:image)
                }
            }
            return req // feed the beast that wants something returned
    }
    
    static  func nwGetJSON(nsurl:NSURL ,completion:NetCompletionFunc )
        throws -> NSMutableURLRequest  {
            
            let req = NSMutableURLRequest(URL: nsurl)
            IGOps.nwEncode(req, parameters: [:])
            IGNetOps.get(req) {statuscode , data in
                if data == nil {
                    print("Api Failure  \(statuscode) in nwGetJSON \(nsurl)")
                }
                else {
                    completion(status:statuscode,object:data)
                }
            }
            return req // feed the beast that wants something returned
    }
    
    static  func nwPost(nsurl:NSURL, params:[String:AnyObject],completion:NetCompletionFunc)
        throws  -> NSMutableURLRequest  {
            let req = NSMutableURLRequest(URL:nsurl)
            IGOps.nwEncode(req, parameters: params)
            IGNetOps.post(req) {statuscode , data in
                if data == nil {
                    print("Api Failure  \(statuscode)   in nwPost \(nsurl)")
                }
                else {
                    completion(status:statuscode,object:data)
                }
            }
            return req // feed the beast that wants something returned
    }
    static  func nwPostFromEncodedRequest(req:NSMutableURLRequest,completion:NetCompletionFunc)
        throws  -> NSMutableURLRequest  {
            print("nwPost pre-encoded req \(req)")
            IGNetOps.post(req) {statuscode , data in
                if data == nil {
                    print("Api Failure  \(statuscode)   in nwPostFromEncodedRequest")
                }
                else {
                    completion(status:statuscode,object:data)
                }
            }
            return req // feed the beast that wants something returned
    }
    
    static func killAllTraffic () {
        session.getAllTasksWithCompletionHandler { taks in
            for task in taks {
                task.cancel()
            }
        }
    }
    
    
}
