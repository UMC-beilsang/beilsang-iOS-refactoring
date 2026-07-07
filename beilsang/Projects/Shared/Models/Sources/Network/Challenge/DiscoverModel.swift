//
//  DiscoverModel.swift
//  ModelsShared
//
//  Created by Seyoung Park on 3/10/26.
//
import Foundation

// MARK: - Achievement Feed
public struct DiscoverFeedPageData: Codable, Sendable {
    public let content: [DiscoverFeed]
    public let number: Int
    public let size: Int
    public let numberOfElements: Int
    public let hasNext: Bool
}

public struct DiscoverFeed: Codable, Sendable, Identifiable, Equatable {
    public let feedId: Int
    public let feedUrl: String
    public let day: Int
    
    public var id: Int { feedId }
    
    public static func == (lhs: DiscoverFeed, rhs: DiscoverFeed) -> Bool {
        lhs.feedId == rhs.feedId
    }
}

// MARK: - Hall of Fame
public struct HallOfFameData: Codable, Sendable {
    public let category: String
    public let challenges: [HallOfFameChallenge]
}

public struct HallOfFameChallenge: Codable, Sendable, Identifiable {
    public let challengeId: Int
    public let title: String
    public let category: String
    public let categoryName: String
    public let startDate: String
    public let finishDate: String
    public let likeCount: Int
    public let attendeeCount: Int
    public let rank: Int
    public let infoImageUrls: [String]
    
    public var id: Int { challengeId }
    public var thumbnailImageUrl: String? {
        infoImageUrls.first
    }
}
