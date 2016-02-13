//
//  FollowersTableView.swift
//  IGExplorer
//
//  Created by bill donner on 1/22/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import UIKit


class FollowersTableView : UITableView {
    var igp: OU! // must be set by creator
    var vc: UIViewController! //likewise
    
    private typealias Follower = OU.UserData
    var followers : OU.BunchOfPeople!
    var mutualFollowerPeople:OU.BunchOfPeople!
    //[IDString:Count]
    var countlikes = 0
    var countlikers = 0
    
    private  func computeMutualFollowers(followers : OU.BunchOfPeople ) -> OU.BunchOfPeople {
        if Globals.shared.igLoggedOnUserID != igp.userID {
            let otherFollowers = Globals.shared.igLoggedOnPersonData!.pd.ouAllFollowers
            /// make mutual followers be the true intersection
            return  Instagram.intersect(otherFollowers,    followers)
        } else {return   [] }
    }
    
    
    
    func deadmansTimer() { self.reloadData() }
    
    func setup (igp:OU, followers:OU.BunchOfPeople, vc:UIViewController,completion:(a:OU.UserData,b:OU.UserData)->(Bool)){
        self.igp  = igp
        self.vc = vc
        mutualFollowerPeople =    computeMutualFollowers(self.igp.pd.ouAllFollowers)
        self.followers = followers
        self.followers.sortInPlace() { a,b in completion(a: a,b: b) }
        
        self.dataSource = self
        self.delegate = self
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "deadmansTimer", userInfo: nil, repeats: true)
        
    }
    
    
}// end of my table view

// MARK: - Table view data source

extension FollowersTableView : UITableViewDataSource , UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowersTypeTableViewCell", forIndexPath: indexPath) as! FollowersTypeTableViewCell
        let  igPerson = self.followers[indexPath.row]
        
        // Configure the cell..
        
        TVC.configFollower(cell,ig:igp,igPerson:igPerson)
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let  f = self.followers[indexPath.row]
        // instead of a segue, lets just make a whole new controller
        if let uiv = UIStoryboard(name:"Main",bundle:nil).instantiateViewControllerWithIdentifier("MainScreenViewControllerID") as? MainScreenViewController {
            uiv.igp = OU(targetID:f.id)
            vc.navigationController?.pushViewController(uiv, animated: true)}
    }
    
}
