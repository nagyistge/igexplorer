
//  IGPersonData.swift
//  SocialMaxx
//
//  Created by bill donner on 1/10/16.
//

// MARK: - IGPerson Info Page


enum IGPersonDataErrors: ErrorType {
    case NoID
    case Bad (arg:Int)
    case CantRestoreIGPersonDataFile(message: String)
    case CantDecodeIGPersonDataFile(message: String)
    case CantWriteIGPersonDataFile(message: String)
}
struct BattleResults {
    let code : Int
    let message : String
}
