//
//  MutualFollowersTableViewController
//  SocialMaxx
//
//  Created by bill donner on 1/4/16.
//

import UIKit

class BattleViewController: UITableViewController {
    private typealias MutualFollower = OU.UserData
    
    var igp : OU! // property
    var results: BattleResults?
    func deadmansTimer() { self.tableView.reloadData() }
    
    var myScore: String = "0" // what we show
    var myAbsoluteScore = 0
    var showScoreMode = false // if true then cell just autoruns the battle
    var currentIndexPath = NSIndexPath(forRow:0,inSection:0)
    var battleResults:[PlayOnBattleResults] = []
    
    var followers: OU.BunchOfPeople! // set by caller now

    deinit {
        //spinner.stopAnimating()
        IGNetOps.killAllTraffic()
    }
    
    @IBAction func unwindToInfoVC (segue : UIStoryboardSegue) {}
    @IBAction func donePressed(sender: AnyObject) {
        self.performSegueWithIdentifier("unwindToPersonDisplaySegueID", sender: self)
    }
    func refreshScoreDisplay() {
        
        self.myScore = "\(self.myAbsoluteScore)"
        if showScoreMode == true {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:self.myScore,style:.Plain,target:self,action:nil )
        }
    }
    func
        handleBattleResults(res:PlayOnBattleResults,atIndexPath indexPath:NSIndexPath) {
            self.myAbsoluteScore = self.myAbsoluteScore
                + res.net
            
            refreshScoreDisplay()
            self.battleResults[indexPath.row] = res //! stash latest
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            
    }
    
    func showScores () {
        // set us into showScoreMode
        showScoreMode = true
        self.navigationItem.rightBarButtonItem = nil
        
        self.navigationItem.promptUser( "Battle is over; results posted below")
        self.tableView.reloadData() // repaint
    }
//    override func viewWillAppear(animated: Bool) {
//        
//        super.viewWillAppear(animated)
//        refreshScoreDisplay()
//        
//    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.editing=false // to close tableviewcell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let _ = followers.map  {_ in
            self.battleResults.append(PlayOnBattleResults())
        }

        self.navigationItem.title = Globals.shared.igLoggedOnPersonData!.userName + " vs "  + self.igp.userName
        self.navigationItem.promptUser("Battle Mode::Swipe Left")
        self.clearsSelectionOnViewWillAppear = false
     self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"ShowMe",style:.Plain,target:self,action:"showScores" )
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "deadmansTimer", userInfo: nil, repeats: false)
    }
    
    @IBAction func unwindToMutualFollowers(segue : UIStoryboardSegue) {
        
        // print("unwindToMutualFollowers \(segue.identifier!)")
        if let def = segue.sourceViewController as? BattleActionViewController {
            if let myresults = def.results  {//pull it back
                handleBattleResults(myresults,atIndexPath:self.currentIndexPath)
                
            }
        }
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
        return followers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowersTypeTableViewCell", forIndexPath: indexPath)
        let  igPerson = followers[indexPath.row]
        if showScoreMode == false { // running one at a time
        let br = self.battleResults[indexPath.row]
        TVC.configPerson(cell,igPerson: igPerson,battleResults:br)
        } else  {
        // always running here and now so run the battle right here
            let (score1,score2) = Battlezone.scoreBattle(p1: self.igp.pd,
                p2: Globals.shared.igLoggedOnPersonData!.pd, p3ID: igPerson.id)
            let ps1 = String(format:"%.2f",score1)
            let ps2 = String(format:"%.2f",score2)
            cell.detailTextLabel?.text = ((score1==score2) ? "tie" : (score1>score2 ? "win":"lose"))
            + " \(ps1) - \(ps2)"
            
        } 
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let  igPerson = followers[indexPath.row]
        if self.battleResults[indexPath.row].result != "" || showScoreMode == true {
            self.performSegueWithIdentifier(
                "FollowerWasSelectedSegue",
                sender: igPerson)
        } else {
            let personID1 = Globals.shared.igLoggedOnUserID
            let personID2 = self.igp.userID
            let igPerson = followers[indexPath.row]
            self.performSegueWithIdentifier("PlayOnActionSegueID", sender:    ["p1":personID1,"p2":personID2,"p3":igPerson.id,"name":igPerson.username,"pic":igPerson.pic])
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        IGNetOps.killAllTraffic() // when moving into a new controlled or going home
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "The Battle List of Mutual Followers list is fully pre-computed after login. We are just scrolling thru the results here. It is computed by removing from the Media Likers all those who are not also my Follower."
        } else if let def = segue.sourceViewController as? BattleActionViewController {
            if let myresults = def.results  {//pull it back
                handleBattleResults(myresults,atIndexPath: self.currentIndexPath)
            }
        } else
            if segue.identifier == "SurrenderActionSegueID" {
                if  let mvc = segue.destinationViewController as? BattleSurrenderViewController {
                    let p1 = sender?.valueForKey("p1")
                    let p2 = sender?.valueForKey("p2")
                    let p3 = sender?.valueForKey("p3")
                    mvc.persons = [p1 as! String,p2 as! String,p3 as! String ]
                }
            } else
                if segue.identifier == "PlayOnActionSegueID" {
                    if  let mvc = segue.destinationViewController as? BattleActionViewController {
                        let nam = sender?.valueForKey("name") as! String
                        let pic = sender?.valueForKey("pic") as! String
                        let p3 = sender?.valueForKey("p3") as! String
                        let bp =  BattleParams(p1:Globals.shared.igLoggedOnPersonData!,
                            p2:self.igp,p3ID:p3)
                        
                        mvc.battleParams = bp
                        mvc.p3Name = nam
                        mvc.p3Pic = pic
                    }
                } else
                    if segue.identifier == "FollowerWasSelectedSegue" {
                        if  let mvc = segue.destinationViewController  as? MainScreenViewController {
                                mvc .modalPresentationStyle = .FullScreen
                                if let f = sender as? OU.UserData  {
                                    mvc.igp = OU(targetID: f.id) // make a new person to fill in
                                }
                        }
        }
    }
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            //"Back pressed"
            IGNetOps.killAllTraffic()
        }
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        self.currentIndexPath = indexPath
        
        let personID1 = Globals.shared.igLoggedOnUserID
        let personID2 = self.igp.userID
        let igPerson = followers[indexPath.row]
        let personID3 = igPerson.id
        let name  = igPerson.username
        let pic  = igPerson.pic
        let surrender = UITableViewRowAction(style: .Normal, title: "Surrender (-1)") { action, index in
            
            // instead do inline instead
            self.myAbsoluteScore += -1
            self.refreshScoreDisplay()
            var res = PlayOnBattleResults()
            res.net = -1
            res.result = "You surrendered!!"
            self.battleResults[index.row] = res
            self.tableView.editing=false // to close tableviewcell
            
            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .None)
        }
        surrender.backgroundColor = UIColor.lightGrayColor()
        
        let play = UITableViewRowAction(style: .Normal, title: "Play On(+-2)") { action, index in
            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .None)
            
            self.performSegueWithIdentifier("PlayOnActionSegueID", sender:    ["p1":personID1,"p2":personID2,"p3":personID3,"name":name,"pic":pic])
        }
        play.backgroundColor = UIColor.orangeColor()
        
        
        return [play, surrender]
    }
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return     showScoreMode ? .None :    .Delete
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return !showScoreMode
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
        if editingStyle == .Delete {
            print ("Hit Delete Path")
        } else {
            print ("Hit Regular Path")
        }
    }
}