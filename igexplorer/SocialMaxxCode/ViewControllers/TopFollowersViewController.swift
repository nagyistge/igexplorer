//
//  TopFollowersViewController.swift
//  IGExplorer
//
//  Created by bill donner on 1/22/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import UIKit

class TopFollowersViewController: UIViewController, FollowersTableKind, SegueThing  {
    var igp : OU! // property passed in
    
    
    func deadmansTimer() { self.tableView.reloadData() }
    @IBOutlet weak var tableView: FollowersTableView!
    @IBAction func unwindToInfoVC (segue : UIStoryboardSegue) {}
    @IBAction func donePressed(sender: AnyObject) {
        self.performSegueWithIdentifier("unwindToPersonDisplaySegueID", sender: self)
    }
  // deinit {}
    func goBattle () {
        self.performSegueWithIdentifier("GoBattleSegueid", sender: self)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        kill(parent)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Top Followers of " + self.igp.userName
        // most of the action is in the custom table view which needs more setup after IB gives it to us
     
        tableView.setup(self.igp,followers:self.igp.pd.ouAllFollowers, vc:self){ a,b  in
            // sort down based on absolute number of likes
            var counter0 = 0
            let z = self.igp.likers[a.id]
            if z == nil { counter0 = 0
            } else {  counter0 = z!.0 }
            var counter1 = 0
            let zz = self.igp.likers[b.id]
            if zz == nil { counter1 = 0
            } else {  counter1 = zz!.0 }
            return counter0 > counter1// descending order
        }

        if tableView.mutualFollowerPeople.count > 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Battles>",style:.Plain, target:self,action:"goBattle")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        IGNetOps.killAllTraffic() // when moving into a new controlled or going home
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "Top Followers Info Goes Here"
        }
        prepFollowerSegue (segue  ,sender:sender,igp:self.igp ,mutuals:tableView.mutualFollowerPeople)
    }
}// end of vc
