//
//  FeedCreateModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Request
public struct FeedCreateRequest: Sendable {
    public let challengeId: Int
    public let review: String
    public let feedImage: Data
    
    public init(challengeId: Int, review: String, feedImage: Data) {
        self.challengeId = challengeId
        self.review = review
        self.feedImage = feedImage
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

