//
//  FeedCreateModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Request
public struct FeedCreateRequest: Codable, Sendable {
    public let challengeId: Int
    public let content: String
    
    public init(challengeId: Int, content: String) {
        self.challengeId = challengeId
        self.content = content
    }
}

// MARK: - Response
public typealias FeedCreateResponse = APIResponse<FeedCreateData>

public struct FeedCreateData: Decodable, Sendable {
    public let feedId: Int
    public let challengeTitle: String
    public let review: String
    public let feedUrl: String
    public let uploadDate: String
    public let createdAt: String
    
    public init(
        feedId: Int,
        challengeTitle: String,
        review: String,
        feedUrl: String,
        uploadDate: String,
        createdAt: String
    ) {
        self.feedId = feedId
        self.challengeTitle = challengeTitle
        self.review = review
        self.feedUrl = feedUrl
        self.uploadDate = uploadDate
        self.createdAt = createdAt
    }
}

