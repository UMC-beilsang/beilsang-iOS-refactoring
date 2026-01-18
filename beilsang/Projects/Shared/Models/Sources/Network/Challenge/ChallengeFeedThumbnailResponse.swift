//
//  ChallengeFeedThumbnailResponse.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/16/25.
//

import Foundation

public struct ChallengeFeedThumbnailResponse {
    public let feeds: [ChallengeFeedThumbnail]
    public let hasNext: Bool
    
    public init(feeds: [ChallengeFeedThumbnail], hasNext: Bool) {
        self.feeds = feeds
        self.hasNext = hasNext
    }
}
