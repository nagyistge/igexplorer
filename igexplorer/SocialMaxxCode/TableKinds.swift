//
//  TableKinds.swift
//  PhotoBrowser
//
//  Created by bill donner on 2/7/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import Foundation

// MARK: - TEMPTEMPTEMP


protocol UivTableKind {
    func  kill(parent: UIViewController?)
    func deadmansTimer()
}
extension UivTableKind {
    
    func  kill(parent: UIViewController?) {
        if parent == nil {
            IGNetOps.killAllTraffic()
        }
    }
}



// MARK: - Follower Type ViewControllers should adopt FollowersTableKind
protocol FollowersTableKind : UivTableKind,SegueThing{
    func prepFollowerSegue (segue:UIStoryboardSegue,sender:AnyObject?,igp:OU,mutuals:OU.BunchOfPeople)
}
extension FollowersTableKind {
    
    func prepFollowerSegue (segue:UIStoryboardSegue,sender:AnyObject?,igp:OU,mutuals:OU.BunchOfPeople) {

                if let f = sender as? OU.UserData  {
                    // Load with followers ID
                    print ("preparing for follower segue for \(f.username)")
                    prepareInjectedData(segue,igp: OU(targetID: f.id))                
             //   }
                } else {
                    
                   // not switching user, just pass current
                    
                    prepareInjectedData(segue, igp: igp)
        }
    }
}

class FollowersTypeTableViewCell: UITableViewCell {
    
}
// MARK: - PeoplesTypeTableViewCell Type ViewControllers should adopt PeoplesTableKind
protocol PeoplesTableKind:UivTableKind,SegueThing {
    func prepPeoplesSegue (segue:UIStoryboardSegue,sender:AnyObject?,igp:OU)
}
extension PeoplesTableKind {
    
    
    func prepPeoplesSegue (segue:UIStoryboardSegue,sender:AnyObject?,igp:OU) {
        
        if segue.identifier == "MediaLikerWasSelectedSegue" {
            if  let mvc = segue.destinationViewController as?  MainScreenViewController  {
                mvc .modalPresentationStyle = .FullScreen
                if let fid = sender as? String {
                    mvc.igp = OU(targetID: fid) // make a new person to fill in
                }
            }
        }
        
        if segue.identifier == "MediaCommenterWasSelectedSegue" {
            if  let mvc = segue.destinationViewController as? MainScreenViewController  {
                mvc .modalPresentationStyle = .FullScreen
                if let fid = sender as? String {
                    mvc.igp = OU(targetID: fid) // make a new person to fill in
                }
            }
        }
        if segue.identifier == "FollowingWasSelectedSegue" {
            if  let mvc = segue.destinationViewController as? MainScreenViewController {
                mvc .modalPresentationStyle = .FullScreen
                if let f = sender as? OU.UserData  {
                    mvc.igp = OU(targetID: f.id) // make a new person to fill in
                }
            }
        }
        
        
        prepareInjectedData(segue,igp:igp)
    }
}
class PeoplesTypeTableViewCell: UITableViewCell {
    
}


// MARK: - Posts Type ViewControllers should adopt PostsTableKind
protocol PostsTableKind : UivTableKind{
}
extension PostsTableKind {
    
}
class PostsTypeTableViewCell: UITableViewCell {
    
}
