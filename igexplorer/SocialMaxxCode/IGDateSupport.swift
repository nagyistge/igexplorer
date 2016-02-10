//
//  IGDateSupport.swift
//  SocialMaxx
//
//  Created by bill donner on 1/17/16. 
//

import Foundation
struct MI {
    var m:Matrix
    var i:Int
}
struct  IGDateSupport {
//    func timeStringFromUnixTime(unixTime: Double,dateFormatter:NSDateFormatter) -> String
//    func dayStringFromTime(unixTime: Double,dateFormatter:NSDateFormatter) -> String
//       func hourBucket(unixTime: Double,dateFormatter:NSDateFormatter)->Int
//    func dayOfWeekBucket(unixTime: Double,dateFormatter:NSDateFormatter)->Int
    
//    func calculateFail()->Matrix
//    func calculateMediaLikesHisto24x7(posts:OU.BunchOfMedia)->MI
//    func calculateMediaPostHisto24x7(posts:OU.BunchOfMedia)->MI
    //
    //func calculateMediaBestPostHisto24x7(posts:OU.BunchOfMedia)->Matrix
}
extension IGDateSupport {
    
    static func hourBucket(unixTime: Double,dateFormatter:NSDateFormatter)->Int {
        let date = NSDate(timeIntervalSince1970: unixTime)
        
        // Returns date formatted as 24 hour time.
        dateFormatter.dateFormat = "HH"
        return Int( dateFormatter.stringFromDate(date))!
        
    }
    static func dayOfWeekBucket(unixTime: Double,dateFormatter:NSDateFormatter)->Int {
        let date = NSDate(timeIntervalSince1970: unixTime)
        
        // Returns date formatted as 24 hour time.
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        dateFormatter.dateFormat = "EEEE"
        let s =  dateFormatter.stringFromDate(date)
        switch s  {
        case "Sunday": return 0
        case "Monday": return 1
        case "Tuesday": return 2
        case "Wednesday": return 3
        case "Thursday": return 4
        case "Friday": return 5
        case "Saturday": return 6
            
        default: fatalError("bad day of week bucket " + s)
            break
        }
        
        
    }
    
    static func timeStringFromUnixTime(unixTime: Double,dateFormatter:NSDateFormatter) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        
        // Returns date formatted as 12 hour time.
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.stringFromDate(date)
    }
    
    static func dayStringFromTime(unixTime: Double,dateFormatter:NSDateFormatter) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.stringFromDate(date)
    }
    static func computeTimeBucketFromIGTimeStamp(ts:String) -> (hourOfDay:Int,dayOfWeek:Int) {
        
        let  dateFormatter = Globals.shared.dateFormatter
            if let dd = Double(ts) {
                let hourOfDay = hourBucket(dd,dateFormatter: dateFormatter)
                let dayOfWeek = dayOfWeekBucket(dd,dateFormatter: dateFormatter)
                return (hourOfDay,dayOfWeek)
            }
        return (hourOfDay:0,dayOfWeek:0)
    }



}