//
//  SpeechlessLikersViewController
//  SocialMaxx
//
//  Created by bill donner on 1/4/16.
//

import UIKit

class SpeechlessLikersViewController: UITableViewController ,PeoplesTableKind,SegueThing {
    
    var igp : OU!// property
  // deinit {}
    
    func deadmansTimer() { self.tableView.reloadData() }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        IGNetOps.killAllTraffic() // when moving into a new controlled or going home
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "The Media Liked list is incrementally produced by using the pagination feature to ask for more data from Instagram every time the end user gets down to the last 80% of this table."
        }
        self.prepPeoplesSegue(segue, sender: sender, igp: self.igp)
    }
    
    var myslikers : [Instagram.Frqc] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Speechless Likers of " + self.igp.userName +  "'s Posts"
        
        let posts = self.igp.pd.ouMediaPosts // all we gots
        
        let (_myslikers,likerscount,likecount) = Instagram.computeFreqCountForSpeechlessLikers(self.igp)
        myslikers = _myslikers
        self.navigationItem.promptUser("\(posts.count) posts, \(likecount) likers, \(likerscount) likes")
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "deadmansTimer", userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myslikers.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MediaLikedTableReuseIdentifier", forIndexPath: indexPath) as! PeoplesTypeTableViewCell
        let  gg = myslikers[indexPath.row]
        cell.textLabel?.text = "Instagram  User \(gg.key)"
        cell.detailTextLabel?.text = "likes:  \(gg.counter) posts"
        
        //Instagram.configPerson(cell,igPerson:gg)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let  pkg = ["a":myslikers[indexPath.row].0,"b":myslikers[indexPath.row].1]
        self.performSegueWithIdentifier("MediaLikerWasSelectedSegue", sender: myslikers[indexPath.row].key)
    }
    
    
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            //"Back pressed"
            IGNetOps.killAllTraffic()
        }
    }
}

