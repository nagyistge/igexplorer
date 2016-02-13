//
//  SegueThings.swift
//  IGExplorer
//
//  Created by bill donner on 1/19/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import UIKit

protocol SegueThing {
    func prepareInjectedData(segue:UIStoryboardSegue,igp:OU)
    
}
extension SegueThing {
    
    func prepareInjectedData(segue:UIStoryboardSegue,igp:OU){
        // Pass the selected object to the new view controller.
        
        //print (">Injecting segue data \(segue.identifier) for \(igp.targetID))")
        //assert(igp.pd.ouUserInfo != nil,"No user info for  \(igp.targetID)")
        
        if let fbvc = segue.destinationViewController as? BoosterFollowersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? SecretAdmirersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? UnrequitedFollowersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? GhostFollowersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? TopPostsSaysFollowersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? SpeechlessLikersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? HeartlessCommentersViewController {
            fbvc.igp = igp
        }
   
        if let fbvc = segue.destinationViewController as? TopPostsByCommentsViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? TopCommentersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? TopLikersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? TopFollowersViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? BattleViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? FollowingTableViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? TopPostsByLikesViewController {
            fbvc.igp = igp
        }
        if let fbvc = segue.destinationViewController as? TopPostsByCommentsViewController {
            fbvc.igp = igp
        }
        if let dvc = segue.destinationViewController as? PrimaryMenuViewController {
            dvc.igp = igp
        }
        if let dvc = segue.destinationViewController as? PeopleReportsMenuViewController {
            dvc.igp = igp
        }
        if let dvc = segue.destinationViewController as? SpecialFollowersReportsMenuViewController {
            dvc.igp = igp
        }
        if let dvc = segue.destinationViewController as? BTPM7x24Controller {
            dvc.igp = igp
        }
        if let dvc = segue.destinationViewController as? WIPM7x24Controller {
            dvc.igp = igp
        }
        if let dvc = segue.destinationViewController as? CalcFailController {
            dvc.igp = igp
        }
        if  let mvc = segue.destinationViewController  as? MainScreenViewController  {
            mvc.igp = igp
        }
        
    }
}