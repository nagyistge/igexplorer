//
//  IGDataEngine.swift
//  SocialMaxx
//
//  Created by bill donner on 1/13/16.
//  NO UIKIT HERE
//

import Foundation
func doThis(dothis: () -> (), thenThat:() -> ()) {
    let _queue = dispatch_queue_create("serial-worker", DISPATCH_QUEUE_SERIAL)
    dispatch_async(_queue) {
        dothis()
        dispatch_async(dispatch_get_main_queue(),{  thenThat() })
    }
}
protocol IGDataEngineDelegate {
    func processRelationshipStatus(d:OU.RelationshipData,loggedInUser:Bool)
    func processFollowersEarly(igp:OU.Player)
    func processIGStuff(igp:OU.Player)
    func processUserStuff (igPerson:OU.UserData,startTime:NSDate )
    func tellUserAboutError(errcode:Int,msg:String,prompt:String,title:String)
    func removeData(userid:String)
}


struct  IGDataEngine {
    // MARK: - Components that are UI free
    private var targetUserID: String
    private var igData:OU
    private var delegate: IGDataEngineDelegate?
    
    init(forLoggedOnUser:String,delegate:IGDataEngineDelegate?) {
        self.targetUserID = forLoggedOnUser
        self.igData = OU(targetID:forLoggedOnUser) // placeholder
        self.delegate = delegate
    }
    
    private mutating func getInstagramStuff(completion:(Int)->()) {
        let apiCountIn = Globals.shared.igApiCallCount
        try! IGOps.loadInstagramBackgroundData(targetUserID){status,m,f in //,l,u,t in
            self.igData.apiCount = Globals.shared.igApiCallCount - apiCountIn
            self.igData.pd.ouAllFollowers = f
            self.igData.pd.ouMediaPosts = m
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(status)
            }
        }// loading closure end
    }
    // MARK: - Utility
    
    private  mutating func fullStartup(startTime:NSDate,completion:IntCompletionFunc) {
        
        // STEP 1
        try! IGOps.getRelationshipstuff(targetUserID) { errcode, statusData in // and then
            guard  errcode == 200 else  {
                print("- fullStartup bail step 1")
                completion(errcode)//
                return
            } // end 1  guard
            // check if its me, in that case
            //if self.targetUserID != Globals.shared.igLoggedOnUserID  {
            if let statusData =  statusData {
                self.igData.pd.ouRelationshipToEndUser = OU.convertRelationshipFrom(statusData)
                self.delegate?.processRelationshipStatus(self.igData.pd.ouRelationshipToEndUser ,loggedInUser:false)
                //   }
            }
            
            // STEP 2
            try!       IGOps.getUserstuff(self.targetUserID){ errcode,igPerson in  // and then
                guard  errcode == 200 else  {
                    //                    self.tellUserAboutError(errcode, msg: "Instagram User Info")
                    print("- fullStartup bail step 2")
                    completion(errcode)
                    return
                } // end 2  guard
                if let igPerson = igPerson {
                    self.igData.pd.ouUserInfo =     OU.convertPersonFrom(igPerson)
                    self.delegate?.processUserStuff (   self.igData.pd.ouUserInfo,startTime: startTime )
                    // STEP 3  get followers, their likes and comments
                    self.getInstagramStuff() { errcode in // and then
                        guard  errcode == 200 else  {
                            self.delegate?.tellUserAboutError(errcode, msg: "Instagram Data Info",prompt:"No IG Data code \(errcode)",title: "Please Accept Our Apologies")
                            self.delegate?.removeData(self.targetUserID)
                            print("- fullStartup bail step 3")
                            return
                        } // end 3  guard
                        self.delegate?.processFollowersEarly(self.igData.pd)
                        self.delegate?.processIGStuff(self.igData.pd)
                        let elapsed = "\(Int(NSDate().timeIntervalSinceDate(startTime)*1000.0))ms"
                        print("Finished loading from Instagram in \(elapsed)")
                        completion (200)
                    } // end 3
                }} // end 2
        } //end 1
    }
    
    private func reloadedFromDisk(startTime:NSDate) {
        if let a = igData.pd.ouRelationshipToEndUser {
            delegate?.processRelationshipStatus(a,loggedInUser:true)
            if let b = igData.pd.ouUserInfo {
                delegate?.processUserStuff ( b,startTime: startTime )
                delegate?.processFollowersEarly(self.igData.pd)
                delegate?.processIGStuff(self.igData.pd)
                //print("--reloaded from disk for id " + igData.userID)
                return
            }
        }
        print("**could not reload from disk for id " + igData.userID)
    }
    
    //forLoggedOnUser
    mutating private func fullstartupRequired(forID:String,completion:PullIntCompletionFunc) {
        let startTime = NSDate()
        // failed to restore, so run the full deal
        FS.shared.bootstrap() // setup temporary filesystem
        self.igData = OU(targetID: forID) //IGPersonData() // scratch
        
        fullStartup(startTime){ errcode in
            
            guard errcode == 200  else {
                self.delegate?.removeData(self.targetUserID)
                // do something
                if errcode == 400 || errcode == 403 {
                    //in this case we can live to fight another day
                    print ("-pullDataForUser error \(errcode) from fullStartup")
                    self.delegate?.tellUserAboutError(
                        errcode, msg: "Privacy error in full startup",
                        prompt:"Can not get personal info from Instagram for this user errcode = \(errcode)",
                        title:"You have no access to this user")
                    return
                }
                fatalError("-- YIKES error \(errcode) from fullStartup, please contact your vendor")
            }
            
            // here it worked ok
            completion(self.igData)
            // write it all to disk, traverses down
            do {
                try self.igData.pd.save(self.targetUserID)
            } catch {
                print("coldnt write ig Plist from fullstartup")
            }}
    }
    
    //MARK: - PullDataForUser is ONLY Externally Called Method
    
    mutating func pullDataForUser(completion:PullIntCompletionFunc) {
        // load user data
        let startTime = NSDate()
        do {
            self.igData.pd = try OU.Player.restore(self.targetUserID)
            // IF STILL HERE WE DID RESTORE SUCCESSFULLY
            self.targetUserID = self.igData.userID
            self.reloadedFromDisk(startTime)
            
            // figure out ll the liker stuff
            igData.likers = Instagram.dictOfAvLikersArossBunchOfMedia(igData.pd.ouMediaPosts)
            completion(self.igData)
            
        }
        catch (_)  {
            //print("--\(err), fullStartup Required")
            print("Contacting Instagram for user data...")
            fullstartupRequired(self.targetUserID) {igd in
                // figure out ll the liker stuff
                self.igData.likers = Instagram.dictOfAvLikersArossBunchOfMedia(self.igData.pd.ouMediaPosts)
                completion(igd)
            }
            
        }// end of catch
    }//pull sR
}