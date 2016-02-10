//
//  BattleSurrenderViewController.swift
//  SocialMaxx
//
//  Created by bill donner on 1/10/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit

class BattleSurrenderViewController: UIViewController {
    var persons:[String]! // set by caller
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        print("Surrender with \(persons)")
    }
}
