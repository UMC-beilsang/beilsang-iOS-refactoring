//
//  BaseEndpoint.swift
//  beilsang
//
//  Created by 강희진 on 2/8/24.
//

import Foundation

enum BaseEndpoint {
    case challenges
    case mypage
    case profile
    case profileImage
    case feeds
    case join
    
    var requestURL: String {
        switch self {
        case .challenges: return URL.makeEndPointString("/api/challenges")
        case .mypage: return URL.makeEndPointString("/api/mypage")
        case .profile: return URL.makeEndPointString("/api/profile")
        case .profileImage: return URL.makeEndPointString("/api/profile/image")
        case .feeds: return URL.makeEndPointString("/api/feeds")
        case .join: return URL.makeEndPointString("/api/join/check/nickname")
        }
    }
}
