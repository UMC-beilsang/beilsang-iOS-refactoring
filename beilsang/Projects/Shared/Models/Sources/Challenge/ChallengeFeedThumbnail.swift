//
//  ChallengeFeedThumbnail.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/16/25.
//

import Foundation

public struct ChallengeFeedThumbnail: Identifiable {
    public let id: Int        // feedId
    public let feedUrl: String // 사진 URL
    public let day: Int       // 몇일차인지
    public let isMyFeed: Bool
    
    public init(feedId: Int, feedUrl: String, day: Int, isMyFeed: Bool) {
        self.id = feedId
        self.feedUrl = feedUrl
        self.day = day
        self.isMyFeed = isMyFeed
    }
}

//extension ChallengeFeedThumbnail {
//    public init(from response: ChallengeFeedData) {
//        self.init(
//            feedId: response.feedId,
//            feedUrl: response.feedUrl,
//            day: response.day
//        )
//    }
//}
