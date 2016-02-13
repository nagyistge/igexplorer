//
//  TableViewCells.swift
//  IGExplorer
//
//  Created by bill donner on 2/7/16.
//  Copyright © 2016 Bill Donner. All rights reserved.
//

import UIKit

struct TVC {
static func configPerson(cell:UITableViewCell,igPerson:OU.UserData,battleResults:PlayOnBattleResults) {
    func explain(br:PlayOnBattleResults)->String{
        if br.surrendered { return "You surrendered!" }
        return br.result
    }
    
    configPerson(cell,igPerson: igPerson)
    if battleResults.result != "" {
        cell.detailTextLabel?.text = explain(battleResults)
        cell.detailTextLabel?.textColor = UIColor.redColor()
    }
}

static func configPerson(cell:UITableViewCell,igPerson:OU.UserData){
    // Configure the cell..
    cell.textLabel!.text = igPerson.username
    cell.detailTextLabel?.text = igPerson.fullname
    
    if igPerson.pic != "" {
        cell.imageView?.imageFromUrl(igPerson.pic) {
            cell.contentView.setNeedsDisplay()
        }
    }
}
static func configFollower(cell:UITableViewCell,ig:OU,igPerson:OU.UserData){
    // Configure the cell..
    
    cell.textLabel!.text = igPerson.username + "(" + igPerson.fullname + ")"
    cell.textLabel!.textColor = UIColor.whiteColor()
    
    if igPerson.pic != "" {
        cell.imageView?.imageFromUrl(igPerson.pic) {
            cell.contentView.setNeedsDisplay()
        }
    }
    
    // see if we found any likers
    var counter = 0
    var avg = 0.0
    let z = ig.likers[igPerson.id]
    if z == nil {
        counter = 0
        avg = 0.0
    } else {
        counter = z!.likes
        avg = Double(z!.likes) /
            Double(ig.pd.ouMediaPosts.count - z!.postsBefore)
    }
    let average = String(format:"%.1f",avg)
    // if counter != 0 {
    cell.detailTextLabel?.text = "\(counter) likes \(average) per "
    //  }
    
}
}