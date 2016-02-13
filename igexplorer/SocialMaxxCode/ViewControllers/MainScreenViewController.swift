 //
 //  MainScreenViewController.swift
 //  SocialMaxx
 //
 //  Created by bill donner on 1/4/16.
 //  Copyright © 2016 SocialMax. All rights reserved.
 //
 
 import UIKit
 
 
 final class MainScreenViewController: UIViewController , FollowersTableKind, SegueThing {
    // var targetUserID: String? // set by caller and passed on thru
    
    var igp: OU! // should be allocated by caller, but not filled in
    
    
    var igDataEngine: IGDataEngine!  // created in viewDidLoad
    var runningNicely: Bool = false
    
    
    // make a new one each time
    @IBOutlet var tgr: UITapGestureRecognizer!
    
    @IBOutlet weak var tableView: FollowersTableView!
    @IBAction func donePressed(sender: AnyObject) {
        // at outer level ??
        
        assert (self.igp != nil)
        
        if self.runningNicely == false {
            removeUserData(self.igp!.targetID)
        }
        if self.runningNicely == true &&
            self.igp.userID == Globals.shared.igLoggedOnUserID  {
                self.performSegueWithIdentifier(
                    "unwindToPhotoBrowser", sender: self)
        } else {
            self.performSegueWithIdentifier(
                "unwindToPersonDisplaySegueID", sender: self)
        }
    }
    
    
    func deadmansTimer() { self.tableView.reloadData() }
    
    // MARK: - ViewController LifeCycle
    deinit {
        if let _targetUserID = self.igp?.targetID {
            if runningNicely == false {
                // if we never got it all together then delete our detritus
                removeUserData(_targetUserID)
            }
        }
        IGNetOps.killAllTraffic()
    }
    func handleUpdateResults(vc:UIViewController,myResults:BattleResults ){
        print("updated by ",vc)
        dump(myResults)
    }
    //unwindToPersonDisplaySegueID
    @IBAction func unwindToPersonDisplayor (segue : UIStoryboardSegue) {

        if let def = segue.sourceViewController as? BattleViewController {
            if let myresults = def.results  {//pull it back
                handleUpdateResults(def,myResults:myresults)
            }
        }
        
    }
    
    func removeUserData(userid:String) {
        
        let path = FS.shared.DocumentsDirectory + "/\(userid).newf.plist"
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
            print("...did delete partial user data for \(userid)")
        } catch     {
            //print("...cant delete partial user data for \(userid)")
        }
    }
    
    func goBattle () {
        self.performSegueWithIdentifier("GoBattleSegueid", sender: self)
    }
    
    override func viewDidLoad() {
        if self.igp == nil { return } // completely bullshit
        super.viewDidLoad()
        
        assert (self.igp != nil)
       
        if let pcview = self.view as?  MainScreenView {
            
            pcview.loggedOn = self.igp!.targetID == Globals.shared.igLoggedOnUserID
            pcview.parent = self // not sure I like this
            pcview.spinner.startAnimating()
            
            self.navigationItem.rightBarButtonItem?.enabled = false
            // Do any additional setup after loading the view.
            self.navigationItem.title = "...loading \(igp!.targetID)..."
            let startTime = NSDate()
            doThis ({
                
                print("****************Loading Instagram Data for user id: \(self.igp!.targetID) ****************")
                self.igDataEngine = IGDataEngine(forLoggedOnUser: self.igp!.targetID, delegate: pcview ) // the big IG Machine Structure with UI callbacks
                
                self.igDataEngine.pullDataForUser() {   igpData in
                    
                    self.igp = igpData
                    self.runningNicely = true
                    // make a persistent record in global space of the first user we set up and pin him up there for future comparisons
                    if Globals.shared.igLoggedOnPersonData == nil {
                        Globals.shared.igLoggedOnPersonData = igpData
                    }
                    
                    let elapsed = "\(Int(NSDate().timeIntervalSinceDate(startTime)*1000.0))ms"
                    print ("Finished pulling Instagram data , elapsed \(elapsed)")
                    
                    pcview.processFinishedLoading(self.igp,elapsed:elapsed)
                    dispatch_async(dispatch_get_main_queue()) {
                        let  itsme  = self.igp!.targetID == Globals.shared.igLoggedOnUserID
                        
                        self.navigationItem.promptUser(itsme ? "YOU" : "A General Instagram User")
                        
                        self.navigationItem.rightBarButtonItem?.enabled = true
                        // finally when all the data is in
                        self.tgr.enabled = true // can move on
                        self.tableView.setup(self.igp,followers:self.igp.pd.ouAllFollowers, vc:self){ a,b  in
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

                        if self.tableView.mutualFollowerPeople.count > 0 {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Battles>",style:.Plain, target:self,action:"goBattle")
                        }
                        
                        
                        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "deadmansTimer", userInfo: nil, repeats: true)
                        
                    }
                } // id of pull data closure
                
                }) // end of background do this
                { // trailing closure
                    //let elapsed = "\(Int(NSDate().timeIntervalSinceDate(startTime)*1000.0))ms"
                    //print ("- background initiation finished at  elapsed \(elapsed)")
            }
            
        } else {
            fatalError("cant load MainScreenView")
        }
       // print ("- pcpvc viewDidLoad finished but background actiities continue")
        self.navigationItem.promptUser("Loading user details from InstaGram...")
    }
 }
 
 // MARK: - Navigation
 extension MainScreenViewController { // nav
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        IGNetOps.killAllTraffic() // when moving into a new
        if  let abc = segue.destinationViewController as? HelpInfoViewController {
            abc.info = "We made \( self.igp.apiCount) API calls to Instagram that we'll be making from the server.  Instead of storing in a database we just leave them in the app. If you want to refresh things just kill and re-run."
        }
        if segue.identifier == "unwindToPersonDisplaySegueID" {
            print("unwinding self to self in mainscreen")
        } else {
            // if going to a follower viewcontroller do special setup
        prepFollowerSegue(segue, sender: sender, igp: self.igp, mutuals: tableView.mutualFollowerPeople) 
            
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            
            dispatch_async(dispatch_get_main_queue()) {
                //"Back pressed"
                IGNetOps.killAllTraffic()
                // if we never got it all together then delete ur detritus
                if self.runningNicely == false {
                    // if we never got it all together then delete our detritus
                    self.removeUserData(self.igp!.targetID)
                }
            }
            
        }
    }
 }