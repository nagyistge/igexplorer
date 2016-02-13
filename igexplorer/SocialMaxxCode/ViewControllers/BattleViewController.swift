//
//  MutualFollowersTableViewController
//  SocialMaxx
//
//  Created by bill donner on 1/4/16.
//

import UIKit

class BattleListTableViewCell: FollowersTypeTableViewCell {
    
}
class BattleViewController: UIViewController, FollowersTableKind, SegueThing   {
    private typealias MutualFollower = OU.UserData
    
    var igp : OU! // property
    var results: BattleResults?
    
    var myScore: String = "0" // what we show
    var myAbsoluteScore = 0
    var showScoreMode = true  // if true then cell just autoruns the battle
    
    var battleResults:[PlayOnBattleResults] = []
    
    var followers: OU.BunchOfPeople! // set by caller now
    
    func deadmansTimer() { self.tableView.reloadData() }
    deinit {
        //spinner.stopAnimating()
        IGNetOps.killAllTraffic()
    }
    @IBOutlet weak var tableView: BattleTableView!
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
        
//        let _ = followers.map  {_ in
//            self.battleResults.append(PlayOnBattleResults())
//        }
        
        
        tableView.setup(self.igp,followers:self.igp.pd.ouAllFollowers, vc:self){ a,b  in
            // sort down based on absolute number of likes
            return a.username < b.username
//            var counter0 = 0
//            let z = self.igp.likers[a.id]
//            if z == nil { counter0 = 0
//            } else {  counter0 = z!.0 }
//            var counter1 = 0
//            let zz = self.igp.likers[b.id]
//            if zz == nil { counter1 = 0
//            } else {  counter1 = zz!.0 }
//            return counter0 > counter1// descending order
        }
        
        self.navigationItem.title = Globals.shared.igLoggedOnPersonData!.userName + " vs "  + self.igp.userName
        self.navigationItem.promptUser("Battle Mode::Swipe Left")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"ShowMe",style:.Plain,target:self,action:"showScores" )
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "deadmansTimer", userInfo: nil, repeats: false)
    }
    
    @IBAction func unwindToMutualFollowers(segue : UIStoryboardSegue) {
        
        // print("unwindToMutualFollowers \(segue.identifier!)")
        if let def = segue.sourceViewController as? BattleActionViewController {
            if let myresults = def.results  {//pull it back
                handleBattleResults(myresults,atIndexPath:self.tableView.currentIndexPath)
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        IGNetOps.killAllTraffic() // when moving into a new controlled or going home
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "The Battle List of Mutual Followers list is fully pre-computed after login. We are just scrolling thru the results here. It is computed by removing from the Media Likers all those who are not also my Follower."
        } else if let def = segue.sourceViewController as? BattleActionViewController {
            if let myresults = def.results  {//pull it back
                handleBattleResults(myresults,atIndexPath: self.tableView.currentIndexPath)
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
}
// MARK: - Table view data source
class BattleTableView : UITableView {
   private  var igp: OU! // must be set by creator
    private var vc: BattleViewController! //likewise
    
    var currentIndexPath = NSIndexPath(forRow:0,inSection:0)
    
    
    private typealias Follower = OU.UserData
    private var followers : OU.BunchOfPeople!
     private var mutualFollowerPeople:OU.BunchOfPeople!
    //[IDString:Count]
    private  var countlikes = 0
    private  var countlikers = 0
    
    private  func computeMutualFollowers(followers : OU.BunchOfPeople ) -> OU.BunchOfPeople {
        if Globals.shared.igLoggedOnUserID != igp.userID {
            let otherFollowers = Globals.shared.igLoggedOnPersonData!.pd.ouAllFollowers
            /// make mutual followers be the true intersection
            return  Instagram.intersect(otherFollowers,    followers)
        } else {return   [] }
    }
    func setup (igp:OU, followers:OU.BunchOfPeople, vc:BattleViewController,completion:(a:OU.UserData,b:OU.UserData)->(Bool)){
        self.igp  = igp
        self.vc = vc
        mutualFollowerPeople =    computeMutualFollowers(self.igp.pd.ouAllFollowers)
        self.followers = followers
        self.followers.sortInPlace() { a,b in completion(a: a,b: b) }
        
        self.dataSource = self
        self.delegate = self
    
    }
}// end of my table view
extension BattleTableView : UITableViewDataSource , UITableViewDelegate{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BattleListTableViewCell", forIndexPath: indexPath) as! BattleListTableViewCell
        let  igPerson = followers[indexPath.row]
        if vc.showScoreMode == false { // running one at a time
            let br = self.vc.battleResults[indexPath.row]
            TVC.configPerson(cell,igPerson: igPerson,battleResults:br)
        } else  {
            
            // Configure the cell..
            
            TVC.configFollower(cell,ig:igp,igPerson:igPerson)
            
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      // let  igPerson = followers[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath) // reclaim the cell
        cell?.contentView.frame.size.height *= 2.0
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        if  self.vc.showScoreMode == true  || self.vc.battleResults[indexPath.row].result != "" {
//            self.vc.performSegueWithIdentifier(
//                "FollowerWasSelectedSegue",
//                sender: igPerson)
//        } else {
//            let personID1 = Globals.shared.igLoggedOnUserID
//            let personID2 = self.igp.userID
//            let igPerson = followers[indexPath.row]
//            self.vc.performSegueWithIdentifier("PlayOnActionSegueID", sender:    ["p1":personID1,"p2":personID2,"p3":igPerson.id,"name":igPerson.username,"pic":igPerson.pic])
//        }
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        self.currentIndexPath = indexPath
        
        let personID1 = Globals.shared.igLoggedOnUserID
        let personID2 = self.igp.userID
        let igPerson = followers[indexPath.row]
        let personID3 = igPerson.id
        let name  = igPerson.username
        let pic  = igPerson.pic
        let surrender = UITableViewRowAction(style: .Normal, title: "Surrender (-1)") { action, index in
            
            // instead do inline instead
            self.vc.myAbsoluteScore += -1
            self.vc.refreshScoreDisplay()
            var res = PlayOnBattleResults()
            res.net = -1
            res.result = "You surrendered!!"
            self.vc.battleResults[index.row] = res
            self.editing=false // to close tableviewcell
            
            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .None)
        }
        surrender.backgroundColor = UIColor.lightGrayColor()
        
        let play = UITableViewRowAction(style: .Normal, title: "Play On(+-2)") { action, index in
            tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .None)
            
            self.vc.performSegueWithIdentifier("PlayOnActionSegueID", sender:    ["p1":personID1,"p2":personID2,"p3":personID3,"name":name,"pic":pic])
        }
        play.backgroundColor = UIColor.orangeColor()
        return [play, surrender]
    }
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return     self.vc.showScoreMode ? .None :    .Delete
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return !self.vc.showScoreMode
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
        if editingStyle == .Delete {
            print ("Hit Delete Path")
        } else {
            print ("Hit Regular Path")
        }
    }
}