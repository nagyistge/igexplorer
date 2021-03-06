//
//  OauthLoginViewController.swift
//  SocialMaxx
//
//  Created by SocialMax on 12/22/14.
//  Copyright (c) 2014 SocialMax. All rights reserved.
//

import UIKit
import Foundation

class OauthLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        webView.hidden = true
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            for cookie in cookies { NSHTTPCookieStorage.sharedHTTPCookieStorage().deleteCookie(cookie)
            }
        }
        
        let request = NSURLRequest(URL: IGOps.Router.requestOauthCode.URLRequest.URL!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        self.webView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToPhotoBrowser" && segue.destinationViewController.isKindOfClass(PhotoBrowserCollectionViewController.classForCoder()) {
            let photoBrowserCollectionViewController = segue.destinationViewController as! PhotoBrowserCollectionViewController
            if let user = sender?.valueForKey("user") as? IGAppUser {
                photoBrowserCollectionViewController.user = user
            }
        }
    }
}

extension OauthLoginViewController: UIWebViewDelegate {
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if  let urlString = request.URL?.absoluteString {
        if let range = urlString.rangeOfString(IGOps.Router.redirectURI + "?code=") {
            
            let location = range.endIndex
            let code = urlString.substringFromIndex(location)
            debugPrint(code)
            requestAccessToken(code)
            return false
        }
        }
        return true
    }
    
    func requestAccessToken(code: String)   {
        
        
       
        do {
            
            
            // get encoded request
            let req = try IGOps.Router.getAccessTokenRequest(code)
            
            // execute as is without additional encoding 
            try IGNetOps.nwPostFromEncodedRequest(req)  {status, jsonObject in
                
            IGJSON.parseIgJSONOAuth(jsonObject!) {accessToken,userID in
                
                
//                let user = Globals.shared.igAppUser
//                
//                user.userID = userID
//                user.accessToken = accessToken
                
                
                Globals.shared.igAppUser.save(userID,accessToken)
                self.performSegueWithIdentifier("unwindToPhotoBrowser", sender: ["user":  Globals.shared.igAppUser])
            } // parse closure
        } // post closure
        }
        catch {
            print ("requestAccessToken failure")
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.hidden = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
    }
}