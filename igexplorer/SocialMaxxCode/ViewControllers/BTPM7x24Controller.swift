//
//  WhenIPostMostResultsController.swift
//  SocialMaxx
//
//  Created by bill donner on 1/17/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import UIKit

// builds of visual view of the marix quintiles on top of an
class BTPM7x24Controller: UIViewController,DrawHistoOps {
    var igp:OU!
    var histo:UIView?
    var alphas: AlphaMatrix!
    var disableDismissButton: Bool = false // if set true then IB button is gone
    
    

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        histo!.removeFromSuperview()
        let bonus:CGFloat = (size.width>size.height) ? 30.0 : -44.0
        let nf = CGRect(x: 0,y: 0,
            width: size.width,height: size.height + bonus)
        self.histo = drawHistoFromMatrix(frame:nf,qm:self.alphas.matrix,colorfunc: DrawnHisto.aColorFunc)
        self.view.addSubview(histo!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.isBeingPresented() {
            // not pushed
            //print ("Presented")
        } else {
           // print ("Not Presented - Pushed?")
        }
        
        if disableDismissButton == true {
            self.navigationItem.leftBarButtonItem = nil 
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(igp != nil)
        self.navigationItem.title  = "When Should I Post?"
        
        // Compute the histogram and fill table data source
        let mi = Instagram.calculateMediaLikesHisto24x7(igp.pd.ouMediaPosts)
        
        self.alphas = AlphaMatrix(m:mi.m)
       // quints = QuintMatrix(m:mi.m)
        let avg = alphas.gs  / (7*24)
        self.navigationItem.promptUser("total likes: \(mi.i) cell max: \(alphas.maxv), avg: \(avg)")// wierdly always shows zero
        let bonus:CGFloat  = (self.view.frame.width > self.view.frame.height) ? 0: 20
        let barh = self.navigationController!.navigationBar.frame.size.height + bonus
        let histoReservedSpace = CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height-barh)
        
        
        self.histo = drawHistoFromMatrix(frame:histoReservedSpace,qm:self.alphas.matrix,colorfunc:DrawnHisto.bColorFunc)

        self.view.addSubview(self.histo!)
        
        print ("Max posts in cell = \(alphas.maxv) Total = \(alphas.gs)")
        
    }
    
}
