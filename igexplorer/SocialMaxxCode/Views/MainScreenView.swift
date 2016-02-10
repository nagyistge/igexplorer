//
//  PCExtensions.swift
//  SocialMaxx
//
//  Created by bill donner on 1/15/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit
import SafariServices

// MARK: - Main View For Main Screen

class MainScreenView: UIView, IGDataEngineDelegate
{
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var names: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    
    var parent:MainScreenViewController?
    var loggedOn:Bool = false
    
    func removeData(userid: String) {       }
    
    func processUserStuff (igPerson:OU.UserData,startTime:NSDate ){
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if "" != igPerson.pic  {
                self.imageView.contentMode = .ScaleAspectFit
                self.imageView?.imageFromUrl(igPerson.pic) {
                    self.imageView.setNeedsDisplay()
                }
            }
            self.parent!.navigationItem.title = igPerson.fullname
            self.names.text  =  igPerson.fullname // self.breadCrumbs! //+ self.names.text!  //+ (" " + name)
            self.names.setNeedsDisplay()
            
            self.bioLabel.text = igPerson.bio
            self.bioLabel.setNeedsDisplay()
            if  "" != igPerson.website {
                self.websiteButton.setTitle(igPerson.website, forState: .Normal)
                self.websiteButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                self.websiteButton.enabled = true
                self.websiteButton.setNeedsDisplay()
            }
            self.parent!.navigationItem.promptUser("loading for \(igPerson.fullname)...")
        }
    }
    func processFollowersEarly(igpp:OU.Player) {
        dispatch_async(dispatch_get_main_queue()) {
            self.parent!.navigationItem.promptUser("loaded  \(igpp.ouAllFollowers.count) followers")
        }}
    func processIGStuff(igpp:OU.Player) {
        dispatch_async(dispatch_get_main_queue()) {
            let _ = igpp.ouUserInfo.username
            self.parent?.runningNicely = true
            self.spinner.stopAnimating()
        }
    }
    func processFinishedLoading(_: OU ,elapsed:String) {
        dispatch_async(dispatch_get_main_queue()) {
                self.spinner.stopAnimating()
        }
    }
    func processRelationshipStatus(d:OU.RelationshipData,loggedInUser:Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            let   privlabel  = d.privacy ? "private" : "public"
            //print("in:\(d.incoming) out:\(d.outgoing), \(privlabel)")
            if loggedInUser{ return}
            if d.hasNoRelationship  {
                if d.privacy {
                    self.backgroundColor = UIColor.darkGrayColor()
                    print(" -- This user is private")
                    
                } else {
                    self.backgroundColor = UIColor.brownColor()
                     print(" -- This user is public but has no relationship to YOU")
                }
                
                self.spinner.stopAnimating()
            }// none and none
            else {
                print("IG Relationship to YOU is in:\(d.incoming) out:\(d.outgoing), \(privlabel)")
            }
        }// let privat
    }
    
    func setButtonsEnabled(b:Bool) {
        dispatch_async(dispatch_get_main_queue()) {
        }
    }
    func tellUserAboutError(errcode:Int,msg:String,prompt:String="",title:String = "") {
        dispatch_async(dispatch_get_main_queue()) {
            self.names.text = errcode == 400 || errcode == 403 ? "Private :(" : "\(msg) Error: \(errcode)"
            self.spinner.stopAnimating()
            self.parent!.navigationItem.promptUser("Can not get personal info from Instagram for this user")
            self.parent!.navigationItem.title = "Private"
            
        }
    }
    
    func presentViewControllerFromParent(vc:UIViewController ) {
        self.parent!.presentViewController(vc, animated: true, completion: nil)
    }
    @IBAction func linktapped(sender: AnyObject) {
        if let surl = self.websiteButton.titleLabel!.text,
            let url = NSURL( string:surl ){
                let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
                self.presentViewControllerFromParent(vc)
        }
    }
}

