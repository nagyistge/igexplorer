//
//  PrimaryMenuViewController.swift
//  SocialMaxx
//
//  Created by bill donner on 1/17/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit

class PrimaryMenuViewController : UIViewController,SegueThing {
    var igp:OU!
    var data: Matrix! // set by super, passed thru
    @IBAction func unwindToCalcMenu(segue:UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(igp != nil)
        self.navigationItem.promptUser(igp.pd.currently())
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        prepareInjectedData(segue,igp:self.igp!)
    }
}
class PeopleReportsMenuViewController : UIViewController,SegueThing {
    var igp:OU!
    var data: Matrix! // set by super, passed thru
    @IBAction func unwindToPeopleReportsMenu(segue:UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(igp != nil)
        self.navigationItem.promptUser(igp.pd.currently())
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        prepareInjectedData(segue,igp:self.igp!)
    }
}
class SpecialFollowersReportsMenuViewController : UIViewController,SegueThing {
    var igp:OU!
    var data: Matrix! // set by super, passed thru
    @IBAction func unwindToSpecialFollowersReportsMenu(segue:UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(igp != nil)
        self.navigationItem.promptUser(igp.pd.currently())
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        prepareInjectedData(segue,igp:self.igp!)
    }
}
class CalcFailController: UIViewController {
    var igp:OU!
    
    
    @IBOutlet weak var labelHeader: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(igp != nil)
        
        //
        // Compute the results and fill table data source
        
        let data = Instagram.calculateFail()
        labelHeader.text  = "Minimal Test Page with rows:\(data.rows) cols:\(data.columns)"
    }
    
}

//