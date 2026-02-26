//
//  ReferralInfo.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import Foundation

/// A shared value type representing referral-related information during signup.
///
/// - `source`: How the user discovered the app (e.g., friend, ad, event).
/// - `recommender`: Nickname or code of the person who referred the user.
///
/// Used in both UI (signup forms) and network requests to the server.
public struct ReferralInfo: Equatable {
    public var source: String?
    public var recommender: String
    
    public init(
        source: String? = nil,
        recommender: String = ""
    ) {
        self.source = source
        self.recommender = recommender
    }
}
