//
//  IGOps.swift
//  SocialMaxx
//
//  Created by bill donner on 1/18/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import Foundation


struct IGOps {
    
    static func loadInstagramBackgroundData(targetID:String,
        completion:(status: Int,
        m:OU.BunchOfMedia,f:OU.BunchOfPeople)->()) throws {
            
            let startTime = NSDate()
            let startCount = Globals.shared.igApiCallCount
            // results will be built up here
            var oumediaBlocks:OU.BunchOfMedia = []
            var oufollowerPeople:OU.BunchOfPeople = []
            
            func phase2loadInstagramBackgroundData() {
                do { // catch any problems in here
                // 2A - get All the Media Posts
             try getmediaPosts(targetID, // run thru all the media posts
                    each:{onepost  in
                        
                        var likerPeopleForThisMediaBlock: BunchOfIGPeople = []
                        
                        // 2B - get Everyone Who Liked this post
                        try! getlikersNonUnique(targetID, //get likers  for this bunch
                            media: onepost,
                            each:{ liker in
                                likerPeopleForThisMediaBlock.append(liker)
                            }) { errc in // getlikersNonUnique completed
                                guard errc == 200 else {
                                    print("getlikersNonUnique failed \(errc)")
                                    completion(status:416,m: [], f: [])
                                    return
                                }
                                let tlikers : OU.BunchOfPeople = OU.convertPeopleFrom(likerPeopleForThisMediaBlock)
                                
                                // 2C - get Comments on this post
                                var commentz: OU.BunchOfComments = []
                                try! getCommentersForMedia(targetID,  mediablock:onepost, each: { commenter in
                                    commentz.append(  OU.convertCommentsFrom( commenter))
                                    }) { errc in // getlikersNonUnique completed
                                        guard errc == 200 else {
                                            print("getCommentersForMedia failed \(errc)")
                                            completion(status:426,m: [], f: [])
                                            return
                                        }
                                        // all comments in at this point, build the post we will store
                                        let reformattedPost  = OU.convertPostFrom(onepost, likers: tlikers,
                                            comments:commentz)
                                        oumediaBlocks.append(reformattedPost)
                                } // end closure for 2C
                        }// end closure for 2B
                    } // end closure for 2A
                    )// getmediaPosts closure begins
                    { err in
                        guard err == 200 else {
                            print ("getmediaPosts failed \(err)")
                            completion(status:415,m: [], f: [])//, l: [], u: [], t: [])
                            return
                        }
                        
                        
                        
                        // sort all the new blocks by creation time and declare victory
                        oumediaBlocks.sortInPlace { Double( $0.createdTime ) < Double( $1.createdTime ) }
                        let since =  "\(Int(NSDate().timeIntervalSinceDate(startTime)*1000.0))"
                        let fresh = Globals.shared.igApiCallCount - startCount
                        print ("-- \(oumediaBlocks.count) media posts finished  in \(since) - \(fresh) api calls")
                        completion(status:200,m: oumediaBlocks, f: oufollowerPeople)                }
                }// do
                catch {
                    print("Error in phase II Startup")
                }
            }// end of phase2
            
            /// phase1 - loadInstagramBackgroundData - get followers
            
            var followerPeople : BunchOfIGPeople = []
            do {
           try  getAllFollowers(targetID,each:{ followers  in
                followerPeople.append(followers)
                }){ errcode1 in
                    guard errcode1 == 200
                        else {
                            print("getAllFollowers failed \(errcode1)")
                            completion(status:414,m: [], f: [])//, l: [], u: [], t: [])
                            return}
                    
                    followerPeople.sortInPlace{ // sort by id order in case of subsequent merge
                        ($0["id"] as! String) < ($1["id"] as! String)
                    }
                    oufollowerPeople = OU.convertPeopleFrom(followerPeople)
                    let since =  "\(Int(NSDate().timeIntervalSinceDate(startTime)*1000.0))"
                    let fresh = Globals.shared.igApiCallCount - startCount
                    let mess = ("-- \(followerPeople.count) followers finished in \(since) - \(fresh) api calls")
                    print(mess)
                    phase2loadInstagramBackgroundData()
            }
            }// do
            catch {
                print ("Caught eror from loadInstagram Background Data")
            }
    }
    
    
    static func getUserstuff (targetID:String,completion:IntPlusOptDictCompletionFunc) throws -> IGOps.Router  {
        let request = IGOps.Router.UserInfo(targetID)
        try IGOps.plainCall(request.URLRequest.URL!,completion: completion)
        return request
    }
    static func getRelationshipstuff (targetID:String,completion:IntPlusOptDictCompletionFunc) throws -> IGOps.Router {
        let request = IGOps.Router.Relationship(targetID)
        try IGOps.plainCall(request.URLRequest.URL!,completion: completion)
        return request
    }
    
    
    static func getmediaPosts(targetID:String,
        each:BOMCompletionFunc,
        completion:IntCompletionFunc) throws  -> IGOps.Router {
            let request = IGOps.Router.MediaRecent(targetID)
            try IGOps.paginatedCall(request.URLRequest.URL!,each: each,completion: completion)
            return request
    }
    
    static func getAllFollowers(targetID:String,
        each:BOPCompletionFunc,
        completion:IntCompletionFunc) throws -> IGOps.Router  {
            let request = IGOps.Router.FollowedBy(targetID)
            try IGOps.paginatedCall(request.URLRequest.URL!,each: each,completion: completion)
            return request
    }
    static func getCommentersForMedia(targetID:String,
        mediablock:IGMediaBlock,
        each:BOMCompletionFunc,
        completion:IntCompletionFunc)  throws -> IGOps.Router {
            let id = mediablock["id"] as? String
            let request = IGOps.Router.MediaComments(id!)
           try IGOps.paginatedCall(request.URLRequest.URL!,each: each,completion: completion)
            return request
    }
    static func getCommenters(targetID:String,
        batchsize:Int,
        media:BunchOfIGMedia,
        each: BOPCompletionFunc,
        completion:IntCompletionFunc) throws {
            let donow = min (media.count,batchsize)
            
            let inner = media[0..<donow].map{ $0 }
            let therest = media[donow+1..<media.count].map { $0 }
            
            
            var countdown = donow
            for s in inner {
              try self.getCommentersForMedia(targetID, mediablock: s,each:each) { success in
                    countdown -= 1
                    if countdown == 0 {
                        if success == 200 {
                         try!  getCommenters(targetID,batchsize: batchsize,
                                media: therest,each: each,completion: completion)
                        }
                        completion(success) }
                }}}
    
    
    
    static func getLikersForMedia(targetID:String,
        mediablock:IGMediaBlock,
        each:BOMCompletionFunc,
        completion:IntCompletionFunc) throws  -> IGOps.Router {
            let id = mediablock["id"] as? String
            let request = IGOps.Router.MediaLikes(id!)
            try IGOps.paginatedCall(request.URLRequest.URL!,each: each,completion: completion)
            return request
    }
    static func getlikers(targetID:String,
        batchsize:Int,
        media:BunchOfIGMedia,
        each: BOPCompletionFunc,
        completion:IntCompletionFunc) throws {
            let donow = min (media.count,batchsize)
            
            let inner = media[0..<donow].map{ $0 }
            let therest = media[donow+1..<media.count].map { $0 }
            
            
            var countdown = donow
            for s in inner {
               try self.getLikersForMedia(targetID, mediablock: s,each:each) { success in
                    countdown -= 1
                    if countdown == 0 {
                        if success == 200 {
                         try!   getlikers(targetID,batchsize: batchsize,
                                media: therest,each: each,completion: completion)
                        }
                        completion(success) }
                }}}
    
    
    
    static func getlikersNonUnique(targetID:String,
        media:IGMediaBlock,
        each: BOPCompletionFunc,
        completion:IntCompletionFunc) throws {
            var countdown = 1
            
            if countdown == 0 { completion(200) }
            //for s in media  { // possibly too much parallelism
            try getLikersForMedia(targetID, mediablock: media,each:each) { success in
                countdown -= 1
                if countdown == 0 { completion(success) }
            }
    }

    static func plainCall(url:NSURL,
        completion:IntPlusOptDictCompletionFunc)  throws {
           try IGNetOps.nwGetJSON(url) { status, jsonObject in
                Globals.shared.igApiCallCount++
                defer {
                }
                IGJSON.parseIgJSONDict(jsonObject!) { code,dict in
                    completion(code,dict)
                }
        }
    }
    
    
    static   func paginatedCall(url:NSURL,
        each:BOMCompletionFunc,
        completion:IntCompletionFunc) throws {
            
           try  IGNetOps.nwGetJSON(url) { status, jsonObject in
                Globals.shared.igApiCallCount++
                defer {
                }
                
              IGJSON.parseIgJSONIgMedia(jsonObject!) {
                        url,resData in
                        for every in resData {
                                each(every)
                            }
                 if url != nil  {
                            let  nextURL = url! // Request = NSURLRequest(URL: url!)
                    // TODO: - put in a proper try someday
                           try! paginatedCall(nextURL,each:each,completion:completion)
                        } else {
                            // no more so run completion
                            completion(200)
                        }
                    }
                   }
    }
    
} // end of IGOps

extension IGOps { // networking
    
    
     static func nwEncode(req:NSMutableURLRequest,parameters:[String:AnyObject]){
        // extracted from Alamofire
        func escape(string: String) -> String {
            let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
            let subDelimitersToEncode = "!$&'()*+,;="
            let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
            allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
            return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? ""
        }
        func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
            var components: [(String, String)] = []
            if let dictionary = value as? [String: AnyObject] {
                for (nestedKey, value) in dictionary {
                    components += queryComponents("\(key)[\(nestedKey)]", value)
                }
            } else if let array = value as? [AnyObject] {
                for value in array {
                    components += queryComponents("\(key)[]", value)
                }
            } else {
                components.append((escape(key), escape("\(value)")))
            }
            
            return components
        }
        func query(parameters: [String: AnyObject]) -> String {
            var components: [(String, String)] = []
            for key in Array(parameters.keys).sort(<) {
                let value = parameters[key]!
                components += queryComponents(key, value)
            }
            
            return (components.map { "\($0)=\($1)" } as [String]).joinWithSeparator("&")
        }
        
        if  let uRLComponents = NSURLComponents(URL: req.URL!, resolvingAgainstBaseURL: false){
        let percentEncodedQuery = (uRLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
      // print("percentEncodedQuery = \(percentEncodedQuery)")
            
        uRLComponents.percentEncodedQuery = percentEncodedQuery
        req.URL = uRLComponents.URL
        }
       // print("nwEncode returns with \(req)")
        return
        
    }
    
    typealias URLParamsToEncode = [String: AnyObject]?
    
    enum Router {
        static let baseURLString = "https://api.instagram.com"
        static let clientID = "cf97d864faf14f90a1557c4b972c990e"
        static let redirectURI = "http://www.example.com/"
        static let clientSecret = "7f1ce6147f924afc92dea31f5354ca06"
        
        case MediaLikes(String)
        case MediaComments(String)
        case UserInfo(String)
        case Relationship(String)
        case MediaRecent(String)
        case SelfMediaLiked( )
        case SelfFollowing()
        case SelfFollowedBy()
        case Following(String) // deprecated by instagram ...soon
        case FollowedBy(String) // deprecated by instagram ...
        case PopularPhotos(String,String) // used by mainline for now
        case requestOauthCode
        
        
        static func getAccessTokenRequest (code:String)throws ->  NSMutableURLRequest {
            let pathString = "/oauth/access_token"
            if let url =  NSURL(string:IGOps.Router.baseURLString + pathString) {
                let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
            var paramString = ""
            for (key, value) in params {
               if let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()),
                let escapedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) {
                paramString += "\(escapedKey)=\(escapedValue)&"
                }
            }
            
            let request = NSMutableURLRequest(URL:url)
            request.HTTPMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
            return request 
        }
        throw IGPersonDataErrors.Bad(arg: 402)
    }
    
        // if let url
//            let urlComponents = NSURLComponents(string:urlString)!
//               urlComponents.queryItems = [
//                
//                 NSURLQueryItem(name: "client_id", value: String(Router.clientID)),
//                
//                NSURLQueryItem(name: "client_secret", value: String(Router.clientSecret)),
//                
//                NSURLQueryItem(name: "grant_type", value: String("authorization_code")),
//                
//                NSURLQueryItem(name: "redirect_uri", value: String(Router.redirectURI)),
//                
//                NSURLQueryItem(name: "code", value: String(code))
//            ]
//           // urlComponents.URL     // returns https://www.google.de/maps/?q=51.500833,-0.141944&z=6
//            let zz = urlComponents.percentEncodedQuery
//            print("-----",zz)
//            let surl = urlComponents.string! // shud now be percent encoded!
//            
//            let freshurl = NSURL(string:surl)
//                        req.HTTPBody = surl.dataUsingEncoding(NSASCIIStringEncoding)
//            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//            [request setHTTPMethod:@"POST"];
//            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//            [request setHTTPBody:[@"firID=800" dataUsingEncoding:NSUTF8StringEncoding]];
//            let params = ["client_id": Router.clientID, "client_secret": Router.clientSecret, "grant_type": "authorization_code", "redirect_uri": Router.redirectURI, "code": code]
//            let pathString = "/oauth/access_token"
//            let urlString = IGOps.Router.baseURLString + pathString
//            let req =  IGOps.encodedRequest(NSURL(string:urlString)!, params: params)

        
        // MARK: URLRequestConvertible
        
        var URLRequest: NSMutableURLRequest {
            let result: (path: String, parameters: URLParamsToEncode ) = {
                switch self {
                    
                case .requestOauthCode:
                    let pathString = "/oauth/authorize/?client_id=" + Router.clientID + "&redirect_uri=" + Router.redirectURI + "&response_type=code"
                    return (pathString, [:])
                    
                case .PopularPhotos (let userID, let accessToken):
                    
                    let params = ["access_token": accessToken ]
                    let pathString = "/v1/users/" + userID + "/media/recent"
                    return (pathString, params)
                    
                default :
                    // these all take the access token
                    let params = ["access_token": Globals.shared.igAccessToken ]
                    
                    switch self {
                        //
                    case .Relationship (let userID):
                        let pathString = "/v1/users/" + userID + "/relationship"
                        return (pathString, params)
                        
                    case .UserInfo (let userID):
                        let pathString = "/v1/users/" + userID
                        return (pathString, params)
                        
                    case .MediaLikes (let mediaID):
                        let pathString = "/v1/media/" + mediaID + "/likes"
                        return (pathString, params)
                        
                    case .MediaComments (let mediaID):
                        let pathString = "/v1/media/" + mediaID + "/comments"
                        return (pathString, params)
                        
                    case .MediaRecent (let userID ):
                        let pathString = "/v1/users/" + userID + "/media/recent"
                        return (pathString, params)
                        
                    case .SelfMediaLiked ():
                        let pathString = "/v1/users/self/media/liked"
                        return (pathString, params)
                        
                    case .Following (let userID ):
                        let pathString = "/v1/users/" + userID + "/follows"
                        return (pathString, params)
                        
                    case .FollowedBy (let userID ):
                        let pathString = "/v1/users/" + userID + "/followed-by"
                        return (pathString, params)
                        
                    case .SelfFollowing ():
                        let pathString = "/v1/users/" + "self" + "/follows"
                        return (pathString, params)
                        
                    case .SelfFollowedBy ():
                        let pathString = "/v1/users/" + "self" + "/followed-by"
                        return (pathString, params)
                        
                        
                    default:
                        return ("",nil)
                        
                    }
                }
            }()
            
            let baseurl = NSURL(string: Router.baseURLString)!
            let fullurl = baseurl.URLByAppendingPathComponent(result.path)
            
            return IGOps.encodedRequest(fullurl, params: result.parameters)
           
        }
    }
    
   static  func encodedRequest(fullurl:NSURL, params:URLParamsToEncode?) -> NSMutableURLRequest {
        
        let parms = (params != nil) ? params! : [:]
        
        let encreq = NSMutableURLRequest(URL:fullurl)
        IGOps.nwEncode(encreq, parameters: parms!)
        
        return encreq
    }

}


