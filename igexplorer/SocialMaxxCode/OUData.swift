//
//  OUData.swift
//  IGExplorer
//
//  Created by bill donner on 1/19/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import Foundation
struct OU {
    typealias BunchOfComments = [CommentData]
    typealias BunchOfMedia = [MediaData]
    typealias BunchOfPeople = [UserData]
    
    var targetID: String = "" // represents the IG userID for this OU
    var pd: Player // let this get changed
    
    // tracks other IG users who like our posts
    var likers : [String:AvLikerReturn] = [:]
    
    init(targetID:String) {
        pd = Player()
        pd.parent = self
        self.targetID = targetID
    }
    
    var apiCount = 0 // not preserced thru the NSCoding classes
    
    // computed properties
    
    var statusOut : String { return pd.ouRelationshipToEndUser.outgoing }
    var statusIn : String {  return pd.ouRelationshipToEndUser.incoming } 
    var userID: String {  return  pd.ouUserInfo.id}
    var userName: String { return  pd.ouUserInfo.username}
    var fullName: String { return  pd.ouUserInfo.fullname }
    var userPic: String? { return  pd.ouUserInfo.pic }
    
    
    @objc  class CommentData :NSObject ,NSCoding{
        var comment: String = ""
        var timestamp : String = ""
        var commentID: String  = ""
        var commenter: UserData?
        
        override init() {}
        
        required init(coder aDecoder:NSCoder) {
            super.init()
            // userID = aDecoder.decodeObjectForKey("id") as? String ?? ""
            comment = aDecoder.decodeObjectForKey("comment") as? String ?? ""
            commentID = aDecoder.decodeObjectForKey("commentID") as? String ?? ""
            timestamp = aDecoder.decodeObjectForKey("timestamp") as? String ?? ""
            commenter = aDecoder.decodeObjectForKey("commenter") as? UserData
        }
        func encodeWithCoder(aCoder: NSCoder) {
            // aCoder.encodeObject(userID, forKey: "id")
            aCoder.encodeObject(comment, forKey: "comment")
            aCoder.encodeObject(commentID, forKey: "commentID")
            aCoder.encodeObject(timestamp, forKey: "timestamp")
            aCoder.encodeObject(commenter, forKey: "commenter")
        }
    }
    @objc  class RelationshipData :NSObject ,NSCoding{
        var incoming: String = ""
        var outgoing : String = ""
        var privacy: Bool = true
        var hasNoRelationship: Bool {
            return incoming=="none" && outgoing=="none"
        }
        
        override init() {}
        
        required init(coder aDecoder:NSCoder) {
            super.init()
            // userID = aDecoder.decodeObjectForKey("id") as? String ?? ""
            incoming = aDecoder.decodeObjectForKey("incoming") as? String ?? ""
            outgoing = aDecoder.decodeObjectForKey("outgoing") as? String ?? ""
            privacy = aDecoder.decodeObjectForKey("isprivate") as? Bool ?? false 
        }
        func encodeWithCoder(aCoder: NSCoder) {
            // aCoder.encodeObject(userID, forKey: "id")
            aCoder.encodeObject(incoming, forKey: "incoming")
            aCoder.encodeObject(outgoing, forKey: "outgoing")
            aCoder.encodeObject(privacy, forKey: "isprivate")
        }
    }
    
    @objc  class UserData :NSObject ,NSCoding{
        var id : String = ""
        var fullname : String = ""
        var username : String = ""
        var pic : String = ""
        // only the /self/uer returns these fields but everyone is in one UserData for now
        var bio : String = ""
        var website: String = "" // of the URL
        override init() {}
        
        required init(coder aDecoder:NSCoder) {
            super.init()
            // userID = aDecoder.decodeObjectForKey("id") as? String ?? ""
            id = aDecoder.decodeObjectForKey("id") as? String ?? ""
            fullname = aDecoder.decodeObjectForKey("fullname") as? String ?? ""
            username = aDecoder.decodeObjectForKey("username") as? String ?? ""
            pic = aDecoder.decodeObjectForKey("pic") as? String ?? ""
            bio = aDecoder.decodeObjectForKey("bio") as? String ?? ""
            website = aDecoder.decodeObjectForKey("website") as? String ?? ""
        }
        func encodeWithCoder(aCoder: NSCoder) {
            // aCoder.encodeObject(userID, forKey: "id")
            aCoder.encodeObject(id, forKey: "id")
            aCoder.encodeObject(fullname, forKey: "fullname")
            aCoder.encodeObject(username, forKey: "username")
            aCoder.encodeObject(pic, forKey: "pic")
            aCoder.encodeObject(bio, forKey: "bio")
            aCoder.encodeObject(website, forKey: "website")
        }
    }
    @objc class MediaData:NSObject,NSCoding  { // keep the likers attached to the media they like
        var id : String = ""
        var createdTime: String = "" // per IG Specs
        var caption: String = "<no caption>"
        var thumbPic: String = "no pic??"
        var standardPic: String = "no pic??"
        var likers: BunchOfPeople?
        var comments: BunchOfComments?
        
        override init() {}
        
        required init(coder aDecoder:NSCoder) {
            super.init()
            id = aDecoder.decodeObjectForKey("id") as? String ?? ""
                 createdTime = aDecoder.decodeObjectForKey("createdTime") as? String ?? ""
                 caption = aDecoder.decodeObjectForKey("caption") as? String ?? ""
            thumbPic = aDecoder.decodeObjectForKey("thumbPic") as? String ?? ""
            standardPic = aDecoder.decodeObjectForKey("standardPic") as? String ?? ""
            likers = aDecoder.decodeObjectForKey("likers") as? BunchOfPeople
               comments = aDecoder.decodeObjectForKey("comments") as? BunchOfComments
        }
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(id, forKey: "id")
            aCoder.encodeObject(createdTime, forKey: "createdTime")
            aCoder.encodeObject(caption, forKey: "caption")
            aCoder.encodeObject(thumbPic, forKey: "thumbPic")
            aCoder.encodeObject(standardPic, forKey: "standardPic")
            aCoder.encodeObject(likers, forKey: "likers")
            aCoder.encodeObject(comments, forKey: "comments")
        }
    }
    
    @objc class Player:NSObject,NSCoding
    {
        //this comes in thru the instagram api
        var ouUserInfo : UserData!
        var ouRelationshipToEndUser:RelationshipData!
        var ouMediaPosts:BunchOfMedia=[] // timesorted by orignal post time
        var ouAllFollowers:BunchOfPeople=[]
        //computed
        var parent:OU?
        var ouLikesCount : Int {
            return ouMediaPosts.reduce(0){
                return ($1.likers != nil ? $0 + $1.likers!.count : $0)
                }
        }
        var ouCommentsCount : Int {
            return ouMediaPosts.reduce(0){
                return ($1.comments != nil ? $0 + $1.comments!.count : $0)
            }
        }
        func currently()->String {
            return "p:\(ouMediaPosts.count) f:\(ouAllFollowers.count) l:\(ouLikesCount) c:\(ouCommentsCount)"
        }
        override init() {}
        
        required init(coder aDecoder:NSCoder) {
            super.init()
            // userID = aDecoder.decodeObjectForKey("id") as? String ?? ""
            ouUserInfo = aDecoder.decodeObjectForKey("user") as? UserData
            ouRelationshipToEndUser = aDecoder.decodeObjectForKey("status") as? RelationshipData
            ouMediaPosts = aDecoder.decodeObjectForKey("posts") as? BunchOfMedia ?? []
            ouAllFollowers = aDecoder.decodeObjectForKey("followers") as? BunchOfPeople ?? []
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            // aCoder.encodeObject(userID, forKey: "id")
            aCoder.encodeObject(ouUserInfo, forKey: "user")
            aCoder.encodeObject(ouRelationshipToEndUser, forKey: "status")            
            aCoder.encodeObject(ouAllFollowers, forKey: "followers")
            aCoder.encodeObject(ouMediaPosts, forKey: "posts")
        }
        func save(userID:String) throws {
            
            let start = NSDate()
            let tail = "/\(userID).newf.plist"
            if  !NSKeyedArchiver.archiveRootObject(self, toFile: FS.shared.DocumentsDirectory + tail){
                throw IGPersonDataErrors.CantWriteIGPersonDataFile(message: tail)
            } else {
                let elapsed  =   "\(Int(NSDate().timeIntervalSinceDate(start)*1000.0))ms"
                print("Wrote API Results File for ", tail, " in ",elapsed)
            }
        }
        
        static func restore(userID:String) throws -> Player {
            let tail = "/\(userID).newf.plist"
            do {
                let start = NSDate()
                if let pdx = NSKeyedUnarchiver.unarchiveObjectWithFile(FS.shared.DocumentsDirectory + tail)  as? Player {
                    
                    let elapsed  =   "\(Int(NSDate().timeIntervalSinceDate(start)*1000.0))ms"
                    print("Restored API Results File from \(tail)", " in ",elapsed)
                    return pdx
                }
                throw IGPersonDataErrors.CantDecodeIGPersonDataFile(message : tail)
            }
            catch  {
                throw  IGPersonDataErrors.CantRestoreIGPersonDataFile (message: tail)
            }
        }
    }
    static func convertRelationshipFrom(relationship:IGAnyBlock) -> OU.RelationshipData    {
        let ob = OU.RelationshipData()
        ob.incoming = relationship["incoming_status"] as! String
        ob.outgoing = relationship["outgoing_status"] as! String
        ob.privacy  = relationship["target_user_is_private"] as! Bool
        return ob
    }
    static   func convertPersonFrom(person:IGUserBlock) -> OU.UserData {
        let ob  = OU.UserData()
        if let id = person ["id"] as? String {ob.id = id
        }
        if let fn = person ["full_name"] as? String {ob.fullname = fn
        }
        if let un = person ["username"] as? String {ob.username = un
        }
        if let un = person ["profile_picture"] as? String {ob.pic = un
        }
        if let un = person ["bio"] as? String {ob.bio = un
        }
        if let un = person ["website"] as? String {ob.website = un
        }
        return ob
    }
    static    func convertCommentsFrom(comments:IGAnyBlock) -> OU.CommentData {
        let ob  = OU.CommentData()
        if let id = comments ["id"] as? String {
            ob.commentID = id
            ob.timestamp = comments["created_time"] as! String
            ob.comment = comments["text"] as! String
            if let igPerson = comments["from"] as? IGUserBlock {
                ob.commenter = convertPersonFrom(igPerson)
            }
        }
       return ob
    }
    static    func convertPeopleFrom(people:BunchOfIGPeople) -> OU.BunchOfPeople {
        return people.map { convertPersonFrom($0) }
    }
    static func convertPostFrom(media:IGMediaBlock, likers:OU.BunchOfPeople, comments: OU.BunchOfComments) -> OU.MediaData{
        // this hugely shrinks the footprint of the app by not story these large chunks
        let ob = OU.MediaData()
        if let id = media  ["id"] as? String {
            
            
            ob.id = id
            ob.likers = likers
            ob.comments = comments
            ob.createdTime = media ["created_time"] as? String ?? ""
            
            if let cap = media["caption"] as? IGAnyBlock,
               let text = cap["text"] as? String {
                       ob.caption = text
               }
            if let g = media["images"] ,
                let ii = g["thumbnail"] as? IGAnyBlock,
                    let s = ii["url"] as? String {
                        ob.thumbPic = s
                        }
                    }
        if let g = media["images"] ,
            let ii = g["standard_resolution"] as? IGAnyBlock,
            let s = ii["url"] as? String {
                ob.standardPic = s
        }
        return ob
    }
}