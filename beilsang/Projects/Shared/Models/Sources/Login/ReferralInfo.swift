//
//  ReferralInfo.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import Foundation

public struct ReferralInfo {
    public var source: String
    public var recommender: String
    
    public init(
        source: String = "",
        recommender: String = ""
    ) {
        self.source = source
        self.recommender = recommender
    }
}
