//
//  SocialMaxxCollectionViewController.swift
//  SocialMaxx
//
//  Created by SocialMax on 12/22/14.
//  Copyright (c) 2014 SocialMax. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class PhotoBrowserCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    
    let formatName = KMSmallImageFormatName
    var shouldLogin = false
    var shouldHump = false
    var user: User? {
        didSet {
            if user != nil {
                handleRefresh()
                hideLogoutButtonItem(false)
                
            } else {
                shouldLogin = true
                hideLogoutButtonItem(true)
            }
        }
    }
    
    var photos = [PhotoInfo]()
    let refreshControl = UIRefreshControl()
    var populatingPhotos = false
    var nextURLRequest: NSURLRequest?
    var coreDataStack: CoreDataStack!
    
    let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
    let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
    
    // MARK: Life-cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        if let fetchRequest = coreDataStack.model.fetchRequestTemplateForName("UserFetchRequest") {
            
            let results = try! coreDataStack.context.executeFetchRequest(fetchRequest) as! [User]
            user = results.first
            shouldHump = true
        } else {
            shouldHump = false
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if shouldLogin {
            performSegueWithIdentifier("login", sender: self)
            shouldLogin = false
        } else         if shouldHump {
            performSegueWithIdentifier("showigcontrollerssegueid", sender: self)
            shouldHump = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToPhotoBrowser (segue : UIStoryboardSegue) {
        
    }
    
    // MARK: CollectionView

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoBrowserCellIdentifier, forIndexPath: indexPath) as! PhotoBrowserCollectionViewCell
        
        let photo = photos[indexPath.row] as PhotoInfo
        
      
        photo.loadPhotoIntoCell(cell,formatName:formatName)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, forIndexPath: indexPath) as! PhotoBrowserLoadingCollectionView
        if nextURLRequest == nil {
            footerView.spinner.stopAnimating()
        } else {
            footerView.spinner.startAnimating()
        }
        return footerView
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let photoInfo = photos[indexPath.row]
        performSegueWithIdentifier("show photo", sender: ["photoInfo": photoInfo])

    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.size.width - 2) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width, height: 100.0)
        collectionView!.collectionViewLayout = layout
    }
    
    func setupView() {
        setupCollectionViewLayout()
        collectionView!.registerClass(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
        collectionView!.registerClass(PhotoBrowserLoadingCollectionView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.nextURLRequest != nil && scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8) {
            try! populatePhotos(self.nextURLRequest!)
        }
    }
    

    
    func populatePhotos(request: NSURLRequest) throws {
        
        if populatingPhotos {
            return
        }
        populatingPhotos = true
        
        try IGNetOps.nwGetJSON (request.URL!) { status, jsonObject in
            Globals.shared.igApiCallCount++
            defer {
                self.populatingPhotos = false
            }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    IGJSON.parseIgJSONPicsStandard(jsonObject!) {url ,photoInfos in
                        
                        if url != nil {
                            self.nextURLRequest = NSURLRequest(URL: url!)
                        } else {
                            self.nextURLRequest = nil
                        }
                        let lastItem = self.photos.count
                        self.photos.appendContentsOf(photoInfos)
                        
                        let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        }
                    }
                }
        }
    }
    
    func handleRefresh() {
        nextURLRequest = nil
        refreshControl.beginRefreshing()
        self.photos.removeAll(keepCapacity: false)
        self.collectionView!.reloadData()
        refreshControl.endRefreshing()
        if user != nil {
            let request = IGOps.Router.PopularPhotos(user!.userID,user!.accessToken)
            try! populatePhotos(request.URLRequest)
        }
    }
    
    func hideLogoutButtonItem(hide: Bool) {
        if hide {
            logoutButtonItem.title = ""
            logoutButtonItem.enabled = false
        } else {
            logoutButtonItem.title = "Logout"
            logoutButtonItem.enabled = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  let fbvc = segue.destinationViewController as? MainScreenViewController {//,
            /// let fbvc = bav.topViewController as?MainScreenViewController  {
            
            fbvc.igp = OU(targetID: (user?.userID)!)
            
            // stash these globally, they dont change anywhere in here
            
            Globals.shared.igLoggedOnUserID = user!.userID
            Globals.shared.igAccessToken = user!.accessToken
            
        } else
            if segue.identifier == "show photo" && segue.destinationViewController.isKindOfClass(PhotoViewerViewController.classForCoder()) {
                let photoViewerViewController = segue.destinationViewController as! PhotoViewerViewController
                photoViewerViewController.photoInfo = sender?.valueForKey("photoInfo") as? PhotoInfo
            } else if segue.identifier == "login" && segue.destinationViewController.isKindOfClass(UINavigationController.classForCoder()) {
                let navigationController = segue.destinationViewController as! UINavigationController
                if let oauthLoginViewController = navigationController.topViewController as? OauthLoginViewController {
                    oauthLoginViewController.coreDataStack = coreDataStack
                }
                
                if self.user != nil {
                    coreDataStack.context.deleteObject(user!)
                    coreDataStack.saveContext()
                    
                }
        }
    }
}
class PhotoBrowserCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    var photoInfo: PhotoInfo?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        imageView.frame = bounds
        addSubview(imageView)
    }
}

class PhotoBrowserLoadingCollectionView: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        spinner.startAnimating()
        spinner.center = self.center
        addSubview(spinner)
    }
}