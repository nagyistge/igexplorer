//
//  FollowingTableViewController
//  SocialMaxx
//
//  Created by bill donner on 1/4/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit

class TopPostsByLikesViewController: UITableViewController, PostsTableKind{
 
    var igp : OU! // property
  // deinit {}
    func deadmansTimer() { self.tableView.reloadData() }
    var freqs : [Instagram.Frqi] = []
    @IBAction func unwindToInfoVC (segue : UIStoryboardSegue) {}
    // if running under a nav controller dont connect in IB if you want to use back button here
    @IBAction func donePressed(sender: AnyObject) {
        self.performSegueWithIdentifier("unwindToPersonDisplaySegueID",
            sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let posts = self.igp.pd.ouMediaPosts // all we gots
        let (_freqs,likecount) = Instagram.computeFreqCountOfLikesForPosts(posts)
        freqs = _freqs // unpack
        self.navigationItem.title = "Top Posts by Likes by " + self.igp.userName
        self.navigationItem.promptUser("Total posts: \(posts.count) likes:\(likecount)")
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "deadmansTimer", userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        IGNetOps.killAllTraffic() // when moving into a new controlled or going home
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "The Recent Posts list is incrementally produced by using the pagination feature to ask for more data from Instagram every time the end user gets down to the last 80% of this table.\n\nIt's import to post a lot if you want good feedback from SocialMax."
        }
        if let photoViewerViewController = segue.destinationViewController as? PhotoViewerViewController {
            photoViewerViewController.photoInfo = sender?.valueForKey("photoInfo") as? PhotoInfo
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return freqs.count
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let  f = self.igp.pd.ouMediaPosts[freqs[indexPath.row].key]
        if "" != f.standardPic {
        let pi  = PhotoInfo(sourceImageURL:NSURL(string: f.standardPic)!)
        performSegueWithIdentifier("show photo", sender: ["photoInfo": pi])
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MediaRecentTableReuseIdentifier", forIndexPath: indexPath) as! PostsTypeTableViewCell
        let  ff = self.igp.pd.ouMediaPosts[freqs[indexPath.row].key]
        let likescount = (ff.likers != nil) ? ff.likers!.count : 0
        let  dateFormatter = Globals.shared.dateFormatter
        cell.textLabel!.text = ff.caption
        if let dd = Double(ff.createdTime) {
            cell.detailTextLabel!.text = IGDateSupport.dayStringFromTime(dd,dateFormatter: dateFormatter) + " " + IGDateSupport.timeStringFromUnixTime(dd,dateFormatter: dateFormatter) + " likes: \(likescount)"
        }
        if ff.thumbPic != "" {
            cell.imageView?.imageFromUrl(ff.thumbPic) {
                cell.contentView.setNeedsDisplay()
            }
        }
        return cell
    }
    
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            //"Back pressed"
            IGNetOps.killAllTraffic()
        }
    }
}