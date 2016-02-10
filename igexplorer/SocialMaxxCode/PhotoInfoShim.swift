//
//  PhotoInfo.swift
//  SocialMaxx
//
//  Created by SocialMax on 1/2/15.
//  Copyright (c) 2015 SocialMax. All rights reserved.
//

// all references to fastimagecache from Parse are in this one file
// hopefully I'll rewrite this someday as pure Swift

import UIKit

let KMPhotoImageFormatFamily = "KMPhotoImageFormatFamily"
let KMSmallImageFormatName = "KMSmallImageFormatName"
let KMBigImageFormatName = "KMBigImageFormatName"

var KMSmallImageSize: CGSize {
    let width = (UIScreen.mainScreen().bounds.size.width - 2) / 3
    return CGSize(width: width, height: width)
}

var KMBigImageSize: CGSize {
    let width = UIScreen.mainScreen().bounds.size.width * 2
    return CGSize(width: width, height: width)
}

class PhotoInfo: NSObject, FICEntity {
    var UUID: String {
        let imageName = sourceImageURL.lastPathComponent!
        let UUIDBytes = FICUUIDBytesFromMD5HashOfString(imageName)
        return FICStringWithUUIDBytes(UUIDBytes)
    }
    
    var sourceImageUUID: String {
        return UUID
    }
    
    var sourceImageURL: NSURL
    var request: NSURLRequest?
    
    init(sourceImageURL: NSURL) {
        self.sourceImageURL = sourceImageURL
        super.init()
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return (object as! PhotoInfo).UUID == self.UUID
    }
    
    func sourceImageURLWithFormatName(formatName: String!) -> NSURL! {
        return sourceImageURL
    }
    
    func drawingBlockForImage(image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        
        let drawingBlock:FICEntityImageDrawingBlock = {
            (context:CGContextRef!, contextSize:CGSize) in
            var contextBounds = CGRectZero
            contextBounds.size = contextSize
            CGContextClearRect(context, contextBounds)
            
            UIGraphicsPushContext(context)
            image.drawInRect(contextBounds)
            UIGraphicsPopContext()
        }
        return drawingBlock
    }
    
    func loadPhotoIntoCell(cell:PhotoBrowserCollectionViewCell,
        formatName:String) {
            
            let sharedImageCache = FICImageCache.sharedImageCache()
            cell.imageView.image = nil
            
            if (cell.photoInfo != self) {
                
                sharedImageCache.cancelImageRetrievalForEntity(cell.photoInfo, withFormatName: formatName)
                
                cell.photoInfo = self
            }
            
            sharedImageCache.retrieveImageForEntity(self, withFormatName: formatName, completionBlock: {
                (photoInfo, _, image) -> Void in
                if (photoInfo as! PhotoInfo) == cell.photoInfo {
                    cell.imageView.image = image
                }
            })
            
    }
    
    
    func getBigPhoto(completion:PhotoCompletion) {
        let sharedImageCache = FICImageCache.sharedImageCache()
        sharedImageCache.retrieveImageForEntity(self, withFormatName: KMBigImageFormatName, completionBlock: {
            ficentity,astring,image in
            completion(self,1,image)
        }) // retrieveImageForEntity
    }
    func getSmallPhoto(completion:PhotoCompletion) {
        let sharedImageCache = FICImageCache.sharedImageCache()
        sharedImageCache.retrieveImageForEntity(self, withFormatName: KMSmallImageFormatName, completionBlock: {
            ficentity,astring,image in
            completion(self,0,image)
        }) // retrieveImageForEntity
    }
    class func setUp(delegate:FICImageCacheDelegate) {
        var imageFormats = [AnyObject]()
        let squareImageFormatMaximumCount = 400;
        let smallImageFormat = FICImageFormat(name: KMSmallImageFormatName, family: KMPhotoImageFormatFamily, imageSize: KMSmallImageSize, style: .Style32BitBGRA, maximumCount: squareImageFormatMaximumCount, devices: .Phone, protectionMode: .None)
        imageFormats.append(smallImageFormat)
        
        let bigImageFormat = FICImageFormat(name: KMBigImageFormatName, family: KMPhotoImageFormatFamily, imageSize: KMBigImageSize, style: .Style32BitBGRA, maximumCount: squareImageFormatMaximumCount, devices: .Phone, protectionMode: .None)
        imageFormats.append(bigImageFormat)
        
        let sharedImageCache = FICImageCache.sharedImageCache()
        sharedImageCache.delegate = delegate
        sharedImageCache.setFormats(imageFormats)
    }
}

// this is unusual, but the FIC is run as an appdelegate extension

extension AppDelegate: FICImageCacheDelegate {
    //MARK: FICImageCacheDelegate
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        PhotoInfo.setUp(self)
        return true
    }
    func imageCache(imageCache: FICImageCache!, wantsSourceImageForEntity entity: FICEntity!, withFormatName formatName: String!, completionBlock: FICImageRequestCompletionBlock!) {
        if let entity = entity as? PhotoInfo {
            let imageURL = entity.sourceImageURLWithFormatName(formatName)
            do {
                try  entity.request = IGNetOps.nwGetImage(imageURL) { status, image in                   completionBlock(image)
                }
            }
            catch {
                print ("nwGetImage failure in imageCache")
            }
        }
    }
    
    func imageCache(imageCache: FICImageCache!, cancelImageLoadingForEntity entity: FICEntity!, withFormatName formatName: String!) {
        
        if let entity = entity as? PhotoInfo, _ = entity.request {
            //request.cancel()
            entity.request = nil
            //debugPrint("be canceled:\(entity.UUID)")
        }
    }
    
    func imageCache(imageCache: FICImageCache!, shouldProcessAllFormatsInFamily formatFamily: String!, forEntity entity: FICEntity!) -> Bool {
        return true
    }
    
    func imageCache(imageCache: FICImageCache!, errorDidOccurWithMessage errorMessage: String!) {
        debugPrint("errorMessage" + errorMessage)
    }
    
    
}

// MARK:- NSURLSessionDataTask to load image in backbround

extension UIImageView {
    public func imageFromUrl(urlString: String,completion:(()->())?) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                if let data = data {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.image = UIImage(data: data)
                        
                        if (completion != nil) { completion!()}
                    }
                }
            })
            task.resume()
        }
    }
}
