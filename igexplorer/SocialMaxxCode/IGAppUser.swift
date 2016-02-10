//
//  IGAppUser
//  igexplorer
//
//  Created by bill donner on 2/10/16.
//  Copyright © 2016 billdonner. All rights reserved.
//

import Foundation
// represents the logged on Instagram User and persists her credentials thru NSUserDefaults
// this is kept as a singleton in the shared Globals

class IGAppUser {
    private(set) var userID:String
    private(set) var accessToken:String
    init(userID:String,token:String) {
        self.userID = userID
        self.accessToken = token
    }
    init() {
        let ns = NSUserDefaults.standardUserDefaults()
        if let _userID = ns.objectForKey("userID") as? String,
            _accessToken = ns.objectForKey("accessToken") as? String {
                userID = _userID
                accessToken = _accessToken
                return}
        userID = ""
        accessToken = ""
        }
    func save() {
        let ns = NSUserDefaults.standardUserDefaults()
        ns.setObject(self.userID,forKey:"userID")
        ns.setObject(self.accessToken,forKey:"accessToken")
        ns.synchronize()
    }
    func save(iuserID:String,_ iaccessToken:String) {
        self.userID = iuserID
        self.accessToken  = iaccessToken
        save()
    }
    func deleteOnLogout() {
        self.userID = ""
        self.accessToken  = ""
        save()
    }
    
}
