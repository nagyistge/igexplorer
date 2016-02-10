//
//  Instagram.swift
//

import Foundation


typealias IGAnyBlock = NSDictionary //[String:AnyObject]
typealias IGStatusBlock = IGAnyBlock
typealias IGMediaBlock = IGAnyBlock
typealias IGUserBlock = IGAnyBlock

typealias AvLikerReturn = (likes:Int,postsBefore:Int)


typealias BunchOfIGMedia = [IGMediaBlock]
typealias BunchOfIGPeople = [IGUserBlock]
typealias BOPCompletionFunc = IGUserBlock->()
typealias BOMCompletionFunc = IGMediaBlock->()
typealias IntCompletionFunc = (Int)->()
typealias IntPlusOptDictCompletionFunc = (Int,[String:AnyObject]?)->()
typealias PullIntCompletionFunc  = (OU -> ())

typealias ParseIgJSONIgPeopleFunc  = (NSURL?,BunchOfIGPeople)->()
typealias ParseIgJSONIgMediaFunc  = (NSURL?,BunchOfIGMedia)->()
typealias ParseIgJSONOAuthFunc  = (String,String)->()
typealias ParseIgJSONPicsStandardFunc  = (NSURL?,[PhotoInfo])->()
typealias ParseIgJSONDictFunc  = (Int,[String : AnyObject])->()

typealias PhotoCompletion = (PhotoInfo,Int, UIImage) -> Void


struct FreqCount {
    let idx:Int
    var frequency:Int
}

struct Instagram {
    
    
    enum IGApiErrors: ErrorType {
        case NoID
        case Bad (arg:Int)
        case FailedToLoadDataFromURL(url : String)
        case CantDecodeIGPersonDataFile(message: String)
        case CantWriteIGPersonDataFile(message: String)
    }
    struct Frqi {
        var key:Int
        var counter = 0
    }
    struct Frqc {
        var key:String
        var counter = 0
    }
        // return tuples that can be divided to get avg :)
    static func dictOfAvLikersArossBunchOfMedia(x:OU.BunchOfMedia) -> [String:AvLikerReturn] {
        var ret : [String:AvLikerReturn] = [:]
        var postcount  = 0
        let _ = x.map {
            if let l = $0.likers {
                let _ =  l.map {
                    let z = $0.id
                    if ret[z] == nil {
                        ret[z] = (likes:1,postsBefore:postcount) }
                    else { let zz = ret[z]
                        ret[z]! =  (likes:zz!.likes + 1,postsBefore:postcount) }
                }
            }
            postcount += 1
        }
        return ret
    }
    static func dictOfLikersArossBunchOfMedia(x:OU.BunchOfMedia) -> [String:Int] {
        var ret : [String:Int] = [:]
        var postcount  = 0
        let _ = x.map {
            if let l = $0.likers {
                let _ =  l.map {
                    let z = $0.id
                    if ret[z] == nil {
                        ret[z] = 1 }
                    else { let zz = ret[z]
                        ret[z]! =  zz! + 1 }
                }
            }
            postcount += 1
        }
        return ret
    }
    
   static func dictOfCommenteursAcrossBunchOfMedia(x:OU.BunchOfMedia) -> [String:Int] {
        var ret : [String:Int] = [:]
        let _ = x.map {
            if let l = $0.comments {
                let _ =  l.map {
                    let z = $0.commenter!.id
                    if ret[z] == nil {
                        ret[z] = 1 }
                    else { let zz = ret[z]
                        ret[z]! == zz! + 1 }
                }
            }
        }
        return ret
    }
    
    // MARK:- Top Likers
    
    static func computeFreqCountForLikers(posts:OU.BunchOfMedia) ->([Frqc],Int,Int) {
        var likers : [String:Int] = [:] //[IDString:Count]
        var slikers : [Frqc] = []
        var countlikes = 0
        var countlikers = 0
        let _ = posts.map { post in
            if  let postLikers = post.likers {
                let _ = postLikers.map { liker in
                    if   let x = likers[liker.id]  {// lookup
                        let newv = x + 1
                        likers[liker.id] = newv
                    } else {
                        likers[liker.id] = 1 // make element, count as 1
                        countlikers += 1
                    }
                    countlikes += 1
                }
                // now we have a dictionary of liker ids and their frequencieser
            }
            
        }//posts.map
        for (key,val) in likers { slikers.append(Frqc(key:key,counter:val))}
        slikers.sortInPlace { $0.counter > $1.counter }// descending by frequency
        return (slikers,countlikes,countlikers)
    }
    // MARK:- Speechless Likers - who have never commented
    

    static func computeFreqCountForSpeechlessLikers(igp:OU) ->([Frqc],Int,Int) {
     
        let p = igp.pd.ouMediaPosts
        let ld = dictOfLikersArossBunchOfMedia(p)
        let cd = dictOfCommenteursAcrossBunchOfMedia(p)
        var slikers : [Frqc] = []
        
        var countlikes = 0
        
        let likersWhoDontComment = inNotIn(ld,cd)
        let _ = likersWhoDontComment.map {key,valInt in
            countlikes += valInt
            slikers.append(Frqc(key:key,counter:valInt))
        }

        slikers.sortInPlace { $0.counter > $1.counter }// descending by frequency
        return (slikers,countlikes,likersWhoDontComment.count)
    }
    // MARK:- Top Commenters
    
    static func computeFreqCountForCommenters(posts:OU.BunchOfMedia) ->([Frqc],Int,Int) {
        var commenteurs : [String:Int] = [:] //[IDString:Count]
        var comments : [Frqc] = []
        var countcomments = 0
        var countcommenteurs = 0
        let _ = posts.map { post in
            if  let postComments = post.comments {
                let _ = postComments.map { comment in
                    if   let x = commenteurs[post.id]  {// lookup
                        let newv = x + 1
                        commenteurs[post.id] = newv
                    } else {
                        commenteurs[post.id] = 1 // make element, count as 1
                        countcommenteurs += 1
                    }
                    countcomments += 1
                }
                // now we have a dictionary of liker ids and their frequencieser
            }
            
        }//posts.map
        for (key,val) in commenteurs { comments.append(Frqc(key:key,counter:val))}
        comments.sortInPlace { $0.counter > $1.counter }// descending by frequency
        return (comments,countcomments,countcommenteurs)
    }
    // MARK:- Heartless Commenters - who dont like anything but post anyways 
    
    static func computeFreqCountForHeartlessCommenters(igp:OU) ->([Frqc],Int,Int) {
            let p = igp.pd.ouMediaPosts
            let ld = dictOfLikersArossBunchOfMedia(p)
            let cd = dictOfCommenteursAcrossBunchOfMedia(p)
            var slikers : [Frqc] = []
            
            var countlikes = 0
            
            let likersWhoDontComment = inNotIn(cd,ld) // perfect inverse
            let _ = likersWhoDontComment.map {key,valInt in
                countlikes += valInt
                slikers.append(Frqc(key:key,counter:valInt))
            }
            
            slikers.sortInPlace { $0.counter > $1.counter }// descending by frequency
            return (slikers,countlikes,likersWhoDontComment.count)
        }
    
    // MARK: - Top Posts By Comments
    
    static func computeFreqCountOfCommentersForPosts(posts:OU.BunchOfMedia) ->([Frqi],Int) {
        
        var slikers : [Frqi] = []
        var totlikes = 0
        var idx = 0
        let _ = posts.map { post in
            if  let postLikers = post.comments {
                let counter = postLikers.count
                slikers.append(Frqi(key: idx ,counter: counter))
                totlikes += counter
                idx += 1
                // now we have a dictionary of liker ids and their frequencieser
            }
        }//posts.map
        slikers.sortInPlace { $0.counter > $1.counter }// descending by frequency
        return (slikers,totlikes)
    }
    
    // MARK: - Top Posts By Likes
    
    static func computeFreqCountOfLikesForPosts(posts:OU.BunchOfMedia) ->([Frqi],Int) {
        
        var slikers : [Frqi] = []
        var totlikes = 0
        var idx = 0
        let _ = posts.map { post in
            if  let postLikers = post.likers {
                let counter = postLikers.count
                slikers.append(Frqi(key: idx ,counter: counter))
                totlikes += counter
                idx += 1
                // now we have a dictionary of liker ids and their frequencieser
            }
        }//posts.map
        slikers.sortInPlace { $0.counter > $1.counter }// descending by frequency
        return (slikers,totlikes)
    }
    
    // MARK: - Top Posts By  FollowersLikes
    
    static func computeFreqCountOfFollowersLikesForPosts(igp:OU) ->([Frqi],Int) {
        func dictById(x:OU.BunchOfPeople) -> [String:Int] {
            var ret : [String:Int] = [:]
            let _ = x.map {
                let z = $0.id
                if (ret[z] != nil) {
                    let cur = ret[z]
                    ret[z] = cur! + 1
                } else { ret[z] = 1 }
            }
            return ret
        }
        
        let f = igp.pd.ouAllFollowers
        let p = igp.pd.ouMediaPosts
        let fd = dictById(f)
        var likersWhoAreFollowers : [String:Int] = [:]
        // go thru all the posts, filter all the likers into dict
        let _ = p.map { pp in
            let _ = pp.likers.map { ls in
                let _ = ls.map { l in
                    if let _ = fd[l.id] {
                        likersWhoAreFollowers[l.id] = 0 // This liker should be included
                    } else {
                        if let cur = likersWhoAreFollowers[l.id] {
                            likersWhoAreFollowers[l.id] = cur + 1
                        }
                        else {
                            assert(true, "likerswhoarefollowers")
                        }
                    }
                }}}
        // now consider only likers who are followers as we count thru
        var slikers : [Frqi] = []
        var totlikes = 0
        var idx = 0
        
        let _ = p.map { post in
             var counter = 0
            if  let postLikers = post.likers {
                let _ = postLikers.map { l in
                    if let _ = likersWhoAreFollowers[l.id] {
                        counter += 1
                    }
                }
            }
            if counter > 0 { // only add
                slikers.append(Frqi(key: idx ,counter: counter))
                totlikes += counter
                idx += 1
            }
            // now we have a dictionary of liker ids and their frequencieser
            
        }//posts.map
        slikers.sortInPlace { $0.counter > $1.counter }// descending by frequency
        return (slikers,totlikes)
    }
    
    
    
    // MARK: - When Do I Post?
    
    static  func calculateMediaPostHisto24x7(posts:OU.BunchOfMedia)-> MI {
        var postsPerBucket = Matrix(rows:7, columns: 24) // filled with zeroes
        
        var totallikerd = 0
        let _ = posts.map  {post in
            
            let z = post.likers != nil ? post.likers!.count : 0
            let (hourOfDay,dayOfWeek) = IGDateSupport.computeTimeBucketFromIGTimeStamp(post.createdTime)
            postsPerBucket[dayOfWeek,hourOfDay] = postsPerBucket[dayOfWeek,hourOfDay]+1
            totallikerd += z
            //}
        }
        return MI(m:postsPerBucket,i:totallikerd)
    }
    
    // MARK: - When Should I Post ?
    static func calculateMediaLikesHisto24x7(posts:OU.BunchOfMedia)->MI {
        
        var postsPerBucket = Matrix(rows:7, columns: 24) // filled with zeroes
        var likesPerBucket = Matrix(rows:7, columns: 24) // filled with zeroes
        var likeRatioBuckets = Matrix(rows:7, columns: 24) // filled with zeroes
        var totallikers = 0
        let _ = posts.map { post in
            let z = post.likers != nil ? post.likers!.count : 0
            let (hourOfDay,dayOfWeek) = IGDateSupport.computeTimeBucketFromIGTimeStamp(post.createdTime)
            postsPerBucket[dayOfWeek,hourOfDay] = postsPerBucket[dayOfWeek,hourOfDay]+1
            likesPerBucket[dayOfWeek,hourOfDay] = likesPerBucket[dayOfWeek,hourOfDay] + Double(z)
            totallikers += z
        }
        for hourOfDay in 0..<likeRatioBuckets.columns {
            for dayOfWeek  in 0..<likeRatioBuckets.rows {
                likeRatioBuckets[dayOfWeek,hourOfDay] =  postsPerBucket[dayOfWeek,hourOfDay] == 0 ? 0 : likesPerBucket[dayOfWeek,hourOfDay] / postsPerBucket[dayOfWeek,hourOfDay]
            }
        }
        
        return MI(m:likeRatioBuckets,i:totallikers)
    }
    // MARK: Calculated To Fail - Dummy
    static func calculateFail()->Matrix {
        let fail = Matrix(rows: 0, columns: 0)
        return fail
    }
    // MARK: Support funcs
    static func removeDuplicates(array:BunchOfIGPeople) -> BunchOfIGPeople {
        var encountered = Set<String>()
        var result: BunchOfIGPeople = []
        for value in array {
            if let id = value["id"] as? String {
                if !encountered.contains(id) {
                    // Do not add a duplicate element.
                    // Add id to the set.
                    encountered.insert(id)
                    // ... Append the value.
                    result.append(value)
                }
            }
        }
        return result
    }
    
    static func reverseFrequencyOrder (aa:OU.BunchOfPeople,
        by:OU.BunchOfPeople) -> OU.BunchOfPeople {
            // reorders the users in aa
            // according to the frequency of references in block by
            // both are assumed to be in sort order, aa must be unique
            var aaidx = 0
            var byidx = 0
            var result:OU.BunchOfPeople = []
            var frequencies :[FreqCount] = []
            let aacount = aa.count
            let bycount = by.count
            for idx in 0..<aacount {
                frequencies.append(FreqCount(idx: idx,frequency: 0))
            }
            while aaidx < aacount && byidx < bycount {
                // depends on short circuit evaluation by &&
                while aaidx < aacount  && (aa[aaidx].id) < (by[byidx].id){
                    aaidx = aaidx + 1
                }
                
                while aaidx < aacount  && byidx < bycount && (aa[aaidx].id) >=  (by[byidx].id) {
                    if (aa[aaidx].id) ==  (by[byidx].id) {
                        
                        frequencies[aaidx].frequency = frequencies[aaidx].frequency + 1
                    }
                    byidx = byidx + 1
                }
            }
            // rearrange results
            frequencies.sortInPlace { $0.frequency>$1.frequency }
            for freq in frequencies {
                result.append(aa[freq.idx])
            }
            return result
    }
    static func intersect(array1: OU.BunchOfPeople,
        _ array2:OU.BunchOfPeople) -> OU.BunchOfPeople {
            var encountered = Set<String>()
            var result: OU.BunchOfPeople = []
            for value in array1 {
                if !encountered.contains(value.id ) {
                    // Do not add a duplicate element.
                    // Add value to the set.
                    encountered.insert(value.id )
                }
            }
            for value in array2 {
                if encountered.contains(value.id) {
                    // Its in both
                    
                    // ... Append the value.
                    result.append(value)
                }
            }
            return result
    }
    
}

func inNotIn(a:[String:Int],_ b:[String:Int]) -> [String:Int] {
    var ret : [String:Int] = [:]
    for (key,val) in a {  if (b[key] != nil) { } else { ret[key] = val }}
    return ret
}
func inAndIn(a:[String:Int],_ b:[String:Int]) -> [String:Int] {
    var ret : [String:Int] = [:]
    for (key,val) in a {  if (b[key] == nil) { } else { ret[key] = val }}
    return ret
}

