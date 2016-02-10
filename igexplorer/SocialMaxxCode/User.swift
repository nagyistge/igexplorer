//
//  User.swift
//  SocialMaxx
//
//  Created by SocialMax on 1/2/15.
//  Copyright (c) 2015 SocialMax. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var userID: String
    @NSManaged var accessToken: String

}
