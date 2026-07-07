//
//  ChallengeDetailModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Response
public typealias ChallengeDetailResponse = APIResponse<ChallengeDetailData>

public struct ChallengeDetailData: Codable, Sendable {
    public let challengeId: Int
    public let title: String
    public let description: String
    public let category: String
    public let startDate: String
    public let finishDate: String
    public let period: String
    public let totalGoalDay: Int
    public let joinPoint: Int
    public let attendeeCount: Int
    public var likeCount: Int      
    public var isLiked: Bool
    public let infoImageUrls: [String]
    public let certImageUrls: [String]
    public let challengeNotes: [String]
    public let isJoinable: Bool
    public let status: ChallengeMemberStatus?
    public let progress: Double?
    public let usedPoint: Int?
    public let earnedPoint: Int?
    public let isRecruitmentClosed: Bool?
}
