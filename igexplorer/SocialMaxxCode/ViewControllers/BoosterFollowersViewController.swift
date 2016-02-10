//
//  TopFollowersViewController.swift
//  PhotoBrowser
//
//  Created by bill donner on 1/22/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

// Booster Followers Have Highest Average Like Rate 

class BoosterFollowersViewController: UIViewController, FollowersTableKind,SegueThing  {
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
        
        self.navigationItem.title = "Booster Followers of " + self.igp.userName
        
        // most of the action is in the custom table view which needs more setup after IB gives it to us
        let postcount = self.igp.pd.ouMediaPosts.count
        tableView.setup(self.igp,followers:self.igp.pd.ouAllFollowers, vc:self) { a,b  in
            // sort down based on average number of likes
            var avg0 = 0.0
            let z = self.igp.likers[a.id]
            if z == nil { avg0 = 0
            } else {  avg0 = Double(z!.0)/Double(postcount - z!.1) }
            var avg1 = 0.0
            let zz = self.igp.likers[b.id]
            if zz == nil { avg1 = 0.0
            } else {  avg1 =  Double(zz!.0)/Double(postcount - zz!.1)}
            return avg0 > avg1// descending order
        }
        if tableView.mutualFollowerPeople.count > 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Battles>",style:.Plain, target:self,action:"goBattle")
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        IGNetOps.killAllTraffic() // when moving into a new controlled or going home
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "Boosters Info Goes Here"
        }
        prepFollowerSegue (segue  ,sender:sender,igp:self.igp ,mutuals:tableView.mutualFollowerPeople)
        

    }
}// end of vc
