//
//  FeedListModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Feed Search Models

public struct SearchFeedItem: Codable, Identifiable, Sendable {
    public let feedId: Int
    public let feedUrl: String
    public let day: Int
    public let isMyFeed: Bool
    
    public var id: Int { feedId }
    
    public init(feedId: Int, feedUrl: String, day: Int, isMyFeed: Bool) {
        self.feedId = feedId
        self.feedUrl = feedUrl
        self.day = day
        self.isMyFeed = isMyFeed
    }
}

public struct SearchFeedPageData: Codable, Sendable {
    public let content: [SearchFeedItem]
    public let number: Int
    public let size: Int
    public let numberOfElements: Int
    public let hasNext: Bool
    
    public var page: Int { number }
    
    public init(content: [SearchFeedItem], number: Int, size: Int, numberOfElements: Int, hasNext: Bool) {
        self.content = content
        self.number = number
        self.size = size
        self.numberOfElements = numberOfElements
        self.hasNext = hasNext
    }
}

// MARK: - Feed List Models

public struct FeedListRequest: Codable, Sendable {
    public let category: String?
    public let page: Int
    public let size: Int
    
    public init(category: String? = nil, page: Int = 0, size: Int = 10) {
        self.category = category
        self.page = page
        self.size = size
    }
}

public struct FeedListResponse: Codable, Sendable {
    public let content: [FeedListItem]
    public let number: Int
    public let size: Int
    public let numberOfElements: Int
    public let hasNext: Bool
    
    public var page: Int { number }
    
    public init(content: [FeedListItem], number: Int, size: Int, numberOfElements: Int, hasNext: Bool) {
        self.content = content
        self.number = number
        self.size = size
        self.numberOfElements = numberOfElements
        self.hasNext = hasNext
    }
}

public struct FeedListItem: Codable, Identifiable, Sendable {
    public let feedId: Int
    public let memberId: Int
    public let memberNickname: String
    public let memberProfileUrl: String
    public let challengeId: Int
    public let challengeTitle: String
    public let category: String
    public let content: String
    public let imageUrl: String
    public let likeCount: Int
    public let isLiked: Bool
    public let createdAt: String
    
    public var feedUrl: String { imageUrl }
    public var id: Int { feedId }
    
    public init(
        feedId: Int,
        memberId: Int,
        memberNickname: String,
        memberProfileUrl: String,
        challengeId: Int,
        challengeTitle: String,
        category: String,
        content: String,
        imageUrl: String,
        likeCount: Int,
        isLiked: Bool,
        createdAt: String
    ) {
        self.feedId = feedId
        self.memberId = memberId
        self.memberNickname = memberNickname
        self.memberProfileUrl = memberProfileUrl
        self.challengeId = challengeId
        self.challengeTitle = challengeTitle
        self.category = category
        self.content = content
        self.imageUrl = imageUrl
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.createdAt = createdAt
    }
}
