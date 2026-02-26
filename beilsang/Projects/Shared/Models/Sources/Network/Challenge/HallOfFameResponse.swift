//
//  HallOfFameResponse.swift
//  ModelsShared
//
//  Created by Seyoung on 11/25/25.
//

import Foundation

// MARK: - API Response
public typealias HallOfFameResponse = APIResponse<HallOfFameData>

public struct HallOfFameData: Codable, Sendable {
    public let category: String
    public let challenges: [HallOfFameChallenge]
}

public struct HallOfFameChallenge: Codable, Sendable {
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
}


