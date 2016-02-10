//
//  BattleActionViewController.swift
//  SocialMaxx
//
//  Created by bill donner on 1/10/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit

class BattleActionViewController: UIViewController {
    // set by caller
    var battleParams: BattleParams!
    var p3Pic: String!
    var p3Name: String!
    
    
    // sent back
    var results:PlayOnBattleResults?
    
    
    var netWinLoss: Int = 0
    var theBackColor:UIColor!
    var theText:String!
    
    
    @IBOutlet weak var p3Comment: UILabel!
    
    
    @IBOutlet weak var score2: UILabel!
    @IBOutlet weak var score1: UILabel!
    
    
    @IBOutlet weak var player1name: UILabel!
    @IBOutlet weak var player2name: UILabel!
    
    @IBOutlet weak var surrenderButton: UIButton!
    
    @IBOutlet weak var hitButton: UIButton!
    @IBOutlet weak var doubleButton: UIButton!
    @IBOutlet weak var p1imageView: UIImageView!
    @IBOutlet weak var p2imageView: UIImageView!
    @IBOutlet weak var p3imageView: UIImageView!
    
   
    func packup(i:Int) -> [String:AnyObject] {
        return ["netbet":i]
    }
    func goUpOneLevel() {
        let args = packup(netWinLoss)
        self.performSegueWithIdentifier("bacToMutualsSeque", sender: args)
    }
    func reveal(v:Int,didSurrender:Bool = false) {
        score1.textColor = UIColor.whiteColor()
        score2.textColor = UIColor.whiteColor()
        
    
        surrenderButton.enabled = false
        surrenderButton.removeFromSuperview()
        hitButton.enabled = false
        hitButton.removeFromSuperview()
        doubleButton.enabled = false
        doubleButton.removeFromSuperview()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "donePressed:")
        if let (color,text,p1s,p2s,winlose) = try? Battlezone.battlescore(battleParams.p1.pd, p2: battleParams.p2.pd, p3ID: battleParams.p3ID) {
            score1.text = String(format:"%.1f",p1s)
            score2.text =  String(format:"%.1f",p2s)
           
            self.netWinLoss = didSurrender ? -1 : winlose*v
            
            self.p3Comment.text = "tied - yawn"
            if self.netWinLoss > 0 { self.p3Comment.text = "You Gained " + "\(self.netWinLoss)" } else
            if self.netWinLoss < 0 { self.p3Comment.text = "You Lost " + "\(-1*self.netWinLoss)" }
            self.view.backgroundColor = didSurrender ? UIColor.lightGrayColor():color
            self.navigationItem.title = didSurrender ? "You surrendered (-1)" :  text
            self.results =
                PlayOnBattleResults(surrendered: didSurrender, result: text, net: self.netWinLoss, p1score: p1s, p2score: p2s)
            
        } else {
            self.view.backgroundColor = UIColor.blackColor()
            print (" ?could not compute battlescore")
        }
    }
   
    func hide() {
        score1.textColor = UIColor.clearColor()
        score2.textColor = UIColor.clearColor()
    }
    @IBAction func surrenderPressed(sender: AnyObject) {
     
        reveal(-1,didSurrender:true)
    }
    
    @IBAction func hitPressed(sender: AnyObject) {
       
        reveal(2)
    }
    
    @IBAction func doubleDownPressed(sender: AnyObject) {
 
        reveal(4)
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        goUpOneLevel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

            player1name.text = battleParams.p1.userName
            if "" != battleParams.p1.userPic {
                p1imageView?.imageFromUrl(battleParams.p1.userPic!) {
                   self.p1imageView!.setNeedsDisplay()
                }
            }
        
            player2name.text = battleParams.p2.userName
            if "" !=  battleParams.p2.pd.ouUserInfo.pic {
                p2imageView?.imageFromUrl(battleParams.p2.userPic!) {
                   self.p2imageView!.setNeedsDisplay()
                }
            }
            
            let ii =  self.p3Pic as String
                p3imageView?.imageFromUrl(ii)
                    {
                    self.p3imageView!.setNeedsDisplay()
            }
            
            self.p3Comment.text = "Here's what " + self.p3Name + " really thinks..."
            hide() // hide the scores
            
 
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "donePressed:")
    }
}
