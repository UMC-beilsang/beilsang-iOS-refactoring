//
//  Const.swift
//  beilsang
//
//  Created by Seyoung on 6/3/24.
//

import Foundation

public struct Const {
    public struct KeyChainKey {
        public static let serverToken = "serverToken"
        public static let refreshToken = "refreshToken"
        public static let authorizationCode = "authorizationCode"
    }

    public struct UserDefaultsKey {
        public static let socialType = "socialType"
        public static let existMember = "existMember"
        public static let recentSearchTerms = "recentSearchTerms"
        public static let deviceToken = "deviceToken"
        public static let firshLaunch = "firshLaunch"
        public static let FCMToken = "FCMToken"
        public static let nicknameExist = "nicknameExist"
    }
}
