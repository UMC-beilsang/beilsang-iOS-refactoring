//
//  Const.swift
//  beilsang
//
//  Created by Seyoung on 6/3/24.
//

import Foundation

struct Const {
    struct KeyChainKey {
        static let serverToken = "serverToken"
        static let refreshToken = "refreshToken"
        static let authorizationCode = "authorizationCode"
    }
    
    struct UserDefaultsKey {
        static let socialType = "socialType"
    //    static let serverToken = "serverToken"
    //    static let refreshToken = "refreshToken"
    //    static let authorizationCode = "authorizationCode"
    //    static let appleRefreshToken = "appleRefreshToken"
        static let existMember = "existMember"
        static let recentSearchTerms = "recentSearchTerms"
        static let deviceToken = "deviceToken"
        static let firshLaunch = "firshLaunch"
        static let FCMToken = "FCMToken"
        static let nicknameExist = "nicknameExist"
    }
}

