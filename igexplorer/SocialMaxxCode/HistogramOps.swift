//
//  HistogramOps.swift
//  SocialMaxx
//
//  Created by bill donner on 1/18/16.
//  Copyright © 2016 SocialMax. All rights reserved.
//

import Foundation
typealias ColorFunc = (Double -> UIColor )
struct DrawnHisto {
    static  func bColorFunc(quint:Double)->UIColor {
        return UIColor.blueColor().colorWithAlphaComponent(CGFloat(quint))
    }
    
    static  func aColorFunc(quint:Double)->UIColor {
        switch Int(quint) {
        case 0: return UIColor.whiteColor()
        case 1: return UIColor.lightGrayColor()
        case 2: return UIColor.grayColor()
        case 3: return UIColor.blueColor()
        case 4: return UIColor.redColor()
        default :
            return UIColor.blackColor()
        }
    }
}
protocol DrawHistoOps {

    func drawHistoFromMatrix(frame oframe:CGRect, qm:Matrix,colorfunc:ColorFunc) -> UIView
    //func aColorFunc(quint:Double)->UIColor
}
extension DrawHistoOps {

    private func buildhistoView(frame:CGRect,matrix:Matrix,colorfunc:ColorFunc) -> UIView {
        
        let dayFor = ["Sun","Mon","Tues","Weds", "Th", "Fri","Sat"]
        let rowlabelwidth:CGFloat  = 30.0
        let collabelheight:CGFloat = 20.0
   
        
        let histo = UIView(frame:CGRect(x:0,y:0,width:frame.width,height:frame.height))
        histo.backgroundColor = UIColor.whiteColor()
        let wspan = (histo.frame.width-rowlabelwidth) / CGFloat(matrix.columns)
        let hspan = (histo.frame.height-collabelheight) / CGFloat(matrix.rows)
        // add 7x24 colored views to histoview
       // print ("histoview \(histo.frame.width)x\(histo.frame.height)   \(wspan)x\(hspan)")
        for j in 0..<matrix.columns {
            let xpos = wspan * CGFloat(j) + rowlabelwidth
            let hframe = CGRectMake(xpos,0,wspan,collabelheight)
            let label = UILabel(frame:hframe)
            label.backgroundColor = UIColor.blackColor()
            label.textColor = UIColor.whiteColor()
            label.text = "\(j)"
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(6)
            histo.addSubview(label)
        }
        for i in 0..<matrix.rows {
            let ypos = hspan * CGFloat(i) + collabelheight
            let labelHeight = (i==matrix.rows-1) ? hspan:hspan-1.0
            let lframe = CGRectMake(0,ypos,rowlabelwidth,labelHeight)
            let label = UILabel(frame:lframe)
            label.backgroundColor = UIColor.blackColor()
            label.textColor = UIColor.whiteColor()
            label.text = dayFor[i]
            label.textAlignment = .Center
            label.font = UIFont.systemFontOfSize(8)
            histo.addSubview(label)
            for j in 0..<matrix.columns {
                let quint = matrix[i,j]
                let color = colorfunc(quint)
                let xpos = wspan * CGFloat(j) + label.frame.width
                let fns = CGRectMake(xpos,ypos,wspan,hspan)
                let newView = UIView(frame:fns)
                newView.backgroundColor = color
                histo.addSubview(newView)
            }
        }
        return histo
    }
    
    func drawHistoFromMatrix(frame oframe:CGRect, qm:Matrix, colorfunc: ColorFunc) -> UIView  {
        let histoReservedSpace = UIView(frame:CGRect(x: 0,y: 0,width: oframe.width,height: oframe.height))
        histoReservedSpace.backgroundColor = UIColor.orangeColor()
        
        let hFrame = UIEdgeInsetsInsetRect(histoReservedSpace.frame,UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0))
        
        let qview = buildhistoView(hFrame,matrix: qm, colorfunc:colorfunc )          // build histov
        
        qview.center = histoReservedSpace.center
        histoReservedSpace.addSubview(qview) // do visual work
        return histoReservedSpace
    }
}