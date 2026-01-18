//
//  FeedLikeModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation

// MARK: - Response
public typealias FeedLikeResponse = APIResponse<FeedLikeData>

public struct FeedLikeData: Decodable, Sendable {
    public let feedId: Int
    public let likeCount: Int
    public let isLiked: Bool
    
    public init(feedId: Int, likeCount: Int, isLiked: Bool) {
        self.feedId = feedId
        self.likeCount = likeCount
        self.isLiked = isLiked
    }
}

