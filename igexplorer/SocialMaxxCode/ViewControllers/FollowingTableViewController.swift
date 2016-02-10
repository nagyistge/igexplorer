//
//  FollowingTableViewController
//  SocialMaxx
//
//  Created by bill donner on 1/4/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit


//// This VC is a bit different - it pulls data incrementally from IG when the user is 80% to the bottom of the screen


class FollowingTableViewController: UITableViewController , PeoplesTableKind{
     private typealias Following = OU.UserData
    
    var igp : OU! // property
    private var followings:[Following] = []
    private var nextURLRequest: NSURLRequest?
    
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    deinit {
        spinner.stopAnimating()
        IGNetOps.killAllTraffic()
    }
    
    
    @IBAction func unwindToInfoVC (segue : UIStoryboardSegue) {}
    
    func process(request: NSURLRequest) throws {
        spinner.startAnimating()
       try IGNetOps.nwGetJSON(request.URL!) {status, jsonObject in
            Globals.shared.igApiCallCount++
            defer {
                self.spinner.stopAnimating()
            }
            IGJSON.parseIgJSONIgPeople(jsonObject!) { url, resData in
                if url != nil {
                    self.nextURLRequest = NSURLRequest(URL: url!)
                } else {
                    self.nextURLRequest = nil
                }
                
                for d in resData {
                    self.followings.append(OU.convertPersonFrom(d))
                }
                self.tableView.reloadData()
            } //parse
        } // nwAny closure
    }
    func deadmansTimer() { self.tableView.reloadData() }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title =  self.igp.userName + " is Following"
        
        self.navigationItem.promptUser(igp.pd.currently())
        
        spinner.color = UIColor.blueColor()
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        // Do any additional setup after loading the view.
        
        //if targetUserID != nil {
        let request = IGOps.Router.Following(self.igp.userID)
        do {
        try process(request.URLRequest)
        
        //}
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "deadmansTimer", userInfo: nil, repeats: true)
        }
        catch {
            print ("Could not Process")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        IGNetOps.killAllTraffic() // when moving into a new controlled or going home
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "This Following list is incrementally produced by using the pagination feature to ask for more data from Instagram every time the end user gets down to the last 80% of this table."
        }
        self.prepPeoplesSegue(segue, sender: sender, igp: self.igp)
        
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingTableReuseIdentifier", forIndexPath: indexPath)
        let  igPerson = followings[indexPath.row]
        // Configure the cell..
        
        TVC.configPerson(cell,igPerson: igPerson)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let  igPerson = followings[indexPath.row]
        
        self.performSegueWithIdentifier("FollowingWasSelectedSegue", sender: igPerson)
    }
    
    // if moving towards bottom then ask for more entries from service
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.nextURLRequest != nil && scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8) {
            try! process(self.nextURLRequest!)
        }
    }
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            //"Back pressed"
            IGNetOps.killAllTraffic()
        }
    }
}

