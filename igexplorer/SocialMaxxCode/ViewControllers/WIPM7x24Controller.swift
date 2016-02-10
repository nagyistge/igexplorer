//
//  WhenIPostMostResultsController.swift
//  SocialMaxx
//
//  Created by bill donner on 1/17/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit

// builds of visual view of the marix quintiles on top of an
class WIPM7x24Controller: UIViewController,DrawHistoOps{
    var igp:OU!
    var histo:UIView?
    var quints:AlphaMatrix!


    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        histo!.removeFromSuperview()
        let bonus:CGFloat = (size.width>size.height) ? 30.0 : -44.0
        let nf = CGRect(x: 0,y: 0,
            width: size.width,height: size.height + bonus)
       self.histo = drawHistoFromMatrix(frame:nf,qm:self.quints.matrix,colorfunc: DrawnHisto.aColorFunc )

        self.view.addSubview(histo!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(igp != nil)
        self.navigationItem.title  = "When I Post Media"
        
        // Compute the histogram and fill table data source
        let mi = Instagram.calculateMediaPostHisto24x7(igp.pd.ouMediaPosts)
        quints = AlphaMatrix(m:mi.m)
        let avg = Float(quints.gs)  / Float (7*24)
        let utilization = mi.i / (7*24)
        self.navigationItem.promptUser("utilization:\(utilization) cell max: \(quints.maxv), avg: \(avg)")// wierdly always shows zero
        
        let bonus:CGFloat  = (self.view.frame.width > self.view.frame.height) ? 0: 20
        let barh = self.navigationController!.navigationBar.frame.size.height + bonus
        let histoReservedSpace = CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height-barh)
//        
         histo = drawHistoFromMatrix(frame:histoReservedSpace,qm:self.quints.matrix, colorfunc: DrawnHisto.bColorFunc )

        self.view.addSubview(histo!)
        
        print ("Max posts in cell = \(quints.maxv) Total = \(quints.gs)")
    }
    
}
