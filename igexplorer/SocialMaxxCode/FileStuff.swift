//
//  FileStuff.swift
//  stories
//
//  Created by william donner on 7/2/15.
//  Copyright © 2015 shovelreadyapps. All rights reserved.
//

import Foundation
class FS {

	class var shared: FS {
		struct Singleton {
			static let sharedAppConfiguration = FS()
		}
		return Singleton.sharedAppConfiguration
	}

 var DocumentsDirectory:String {
	return NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String + "/" + "Private Documents"
	}
 var ItunesInboxDirectory:String {
	return NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
	}
	var TemporaryDirectory:String {
		return NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as String + "/" + "tmp"
	}
	
    
    func bootstrap() {
		resetTempFiles()
		createDir(DocumentsDirectory)
		/// Itunes Inbox is where we share with local files
	}

 func resetTempFiles() {
	var error:NSError?
	do {
		try NSFileManager.defaultManager().removeItemAtPath(TemporaryDirectory)
	} catch let error1 as NSError {
		error = error1
	}
	if (error != nil) { //errln("Cant remove temp directory \(error)")
	}
	do {
		try NSFileManager.defaultManager().createDirectoryAtPath(TemporaryDirectory, withIntermediateDirectories:true,    attributes: nil)
	} catch let error1 as NSError {
		error = error1
	}
	if (error != nil) { //errln("Cant create temp directory \(error)")
	}
	}//

	func createDir(dir:String) {  // Private
		var error:NSError?
		if NSFileManager.defaultManager().fileExistsAtPath(dir) == false {
			do {
				try NSFileManager.defaultManager().createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
			} catch let error1 as NSError {
				error = error1
			}
			if (error != nil) {
				//errln("Cant create dir \(dir) \(error)")
			}
			if NSFileManager.defaultManager().fileExistsAtPath(dir) == false {
				print ("Cant create dir \(dir) failed on re-read")
			}
            else {
             //print("- Created dir \(dir)")
            }
		} else {
			//print  ("cant create because Directory exists -> \(dir)")
		}
	}
	
}
