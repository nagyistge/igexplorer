//
//  HelpInfoViewController.swift
//  SocialMaxx
//
//  Created by bill donner on 1/6/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit

class HelpInfoViewController: UIViewController {
    var info: String? // must be set by caller

    @IBOutlet weak var infoLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if info != nil {
            infoLabel.text = info 
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
