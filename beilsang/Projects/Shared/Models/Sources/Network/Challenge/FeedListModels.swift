//
//  FeedListModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Request
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

// MARK: - Response
public struct FeedListResponse: Codable, Sendable {
    public let content: [FeedListItem]
    public let number: Int
    public let size: Int
    public let numberOfElements: Int
    public let hasNext: Bool
    
    public init(content: [FeedListItem], number: Int, size: Int, numberOfElements: Int, hasNext: Bool) {
        self.content = content
        self.number = number
        self.size = size
        self.numberOfElements = numberOfElements
        self.hasNext = hasNext
    }
}

public struct FeedListItem: Codable, Sendable {
    public let feedId: Int
    public let feedUrl: String
    public let day: Int
    
    public init(feedId: Int, feedUrl: String, day: Int) {
        self.feedId = feedId
        self.feedUrl = feedUrl
        self.day = day
    }
}

