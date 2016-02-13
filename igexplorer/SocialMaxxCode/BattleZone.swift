//
//  BattleZone.swift
//  IGExplorer
//
//  Created by bill donner on 1/23/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import Foundation


struct BattleParams {
    let p1 : OU
    let p2 : OU
    let p3ID : String
}
struct PlayOnBattleResults {
    var surrendered = false
    var result: String=""
    var net:Int=0
    var p1score:Float=0
    var p2score:Float=0
}
struct Battlezone {
    enum BattlezoneError: ErrorType {
        case NoID
        case Bad2 (arg:Int)
        
    }
    static func isLikerOf(post:OU.MediaData,personID chrisID:String) -> Bool {
        for liker in post.likers! {
            if liker.id == chrisID {return true}
        }
        return false
    }
    static func firstTimeLiking(p1:OU.Player,chrisID:String)->Double {
        // out media posts are presumed time ordered
        let posts = p1.ouMediaPosts
        // 1 -
        for post in posts {
            if isLikerOf(post,personID: chrisID) {return Double(post.createdTime)!}
        }
        return 0.0
    }
    static func postsAndLikesSinceFirstLike(p1:OU.Player,
            personID chrisID:String) -> (posts:Int,likes:Int) {
                var haveLiked = false
                var countPostsSinceHaveLiked = 0
                var countLikesSinceHaveLiked = 0
                // out media posts are presumed time ordered
                let posts = p1.ouMediaPosts
                // 1 -
                for post in posts {
                    if isLikerOf(post,personID: chrisID) {
                        haveLiked = true
                        countLikesSinceHaveLiked += 1
                    }
                    if haveLiked == true {
                        countPostsSinceHaveLiked += 1
                    }
                }
        return (countPostsSinceHaveLiked,countLikesSinceHaveLiked)
    }
    
    
//    func firstTimeEachPosting (p1:OU.Player,p2:OU.Player){
//        // assuming media posts in time sorted order, find the first time both were posting
//        let minTime1 = Double(p1.ouMediaPosts[0].createdTime)
//        let minTime2 = Double(p2.ouMediaPosts[0].createdTime)
//        var idx1 = 0
//        var idx2 = 0
//        let count1  = p1.ouMediaPosts.count,
//        count2 = p2.ouMediaPosts.count
//        guard   count1 != 0  && count2 != 0  else {
//            return (0.0,0.0)
//        }
//        
//        if minTime2 < minTime1 { // this test may be redundant
//            
//            while idx2 < count2 && // short circuit eval needed here
//                Double(p2.ouMediaPosts[idx2].createdTime) < minTime1 {
//                    idx2 += 1 }
//        }
//        
//        if minTime1 < minTime2 {
//            
//            while idx1 < count1 &&
//                Double(p1.ouMediaPosts[idx1].createdTime) < Double(p2.ouMediaPosts[idx2].createdTime) {
//                    idx1 += 1 }
//        } else {
//            // same
//        }
//    }// func
    //
    // a Battle is a runthru of all the mutual Followers of p1 and p2, computing a score based on the how many Posts of each of p1 and p2 were liked by p3 (since each of p1 and p2 were both posting)
    
    static func scoreBattle(p1 p1:OU.Player, p2:OU.Player, p3ID chrisID:String) -> (p1score:Float,p2score:Float) {
        // first figure out the time at which bost are posting
        let count1  = p1.ouMediaPosts.count,
        count2 = p2.ouMediaPosts.count
        guard   count1 != 0  && count2 != 0  else {
            return (0.0,0.0)
        }
        
        let (p1posts,p1likes) = postsAndLikesSinceFirstLike(p1,personID:chrisID)
        
        let (p2posts,p2likes) = postsAndLikesSinceFirstLike(p2,personID:chrisID)
        //firstTimeEachPosting()
      
        
//        
//        // now we have the beginning points of where to count likes
//        
//        var p1count = 0
//        let _ = p1.ouMediaPosts[idx1..<count1].map{ post in
//            if  let likers = post.likers {
//                for liker in likers {
//                    if liker.id == chrisID {
//                        p1count += 1 } }
//            }
//        }
//        var p2count = 0
//        let _ = p2.ouMediaPosts[idx2..<count2].map {post in
//            if  let likers = post.likers {
//                for liker in likers {
//                    if liker.id == chrisID {
//                        p2count += 1 } }
//            }
//        }
        
        // we have roughly the #of likes from Chris to each of p1 and p2 from the same point in time
        // so scale each by the number of posts in that period
        
        let p1raw = p1posts == 0 ? 0.0 : Float(p1likes)/Float(p1posts)
        //count1 == idx1 ? Float(0) : Float(p1count) / Float(count1-idx1)
        let p2raw = p2posts == 0  ? 0.0 : Float(p2likes)/Float(p2posts)
        //count2 == idx2 ? Float(0) : Float(p2count) / Float(count2-idx2)
        
        // so, if you've posted only a few since then and they've been all liked YOU win
        // but if you never posted anything you gt a zero
        // just normalize from 0-10
        return (p1raw*10.0,p2raw*10.0)
    }
    static func battlescore(p1:OU.Player, p2:OU.Player, p3ID chrisID:String)
        throws -> (UIColor,String,Float,Float,Int) {
            
            let (jamesScore , honeyScore) = scoreBattle (p1: p1,p2: p2,p3ID: chrisID)
            
            let jamesPretty = String(format:"%.1f",jamesScore)
            let honeyPretty = String(format:"%.1f",honeyScore)
            
            if jamesScore > honeyScore {
                return (UIColor.blueColor(),
                    " You Win \(jamesPretty) to \(honeyPretty)",
                    jamesScore,honeyScore,+1)
            } else if honeyScore > jamesScore {
                return (UIColor.redColor()," You Lose \(honeyPretty) to \(jamesPretty)",
                    jamesScore,honeyScore,-1)
            } else { // tie
                return (UIColor.orangeColor()," Tie -  \(honeyPretty) to \(jamesPretty) ",jamesScore,honeyScore,0)
            }
    }
}


