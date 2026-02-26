//
//  FeedsByCategoryResponse.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation

// MARK: - API Response
public typealias FeedsByCategoryResponse = APIResponse<FeedsByCategoryData>

public struct FeedsByCategoryData: Codable, Sendable {
    public let content: [FeedItem]
    public let number: Int
    public let size: Int
    public let numberOfElements: Int
    public let hasNext: Bool
}

public struct FeedItem: Codable, Sendable {
    public let feedId: Int
    public let feedUrl: String
    public let day: Int
}

