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
    public let startDate: String // "YYYY-MM-DD"
    public let finishDate: String // "YYYY-MM-DD"
    public let period: String // "WEEK", "MONTH"
    public let totalGoalDay: Int
    public let joinPoint: Int
    public let attendeeCount: Int
    public let likeCount: Int
    public let infoImageUrls: [String]
    public let certImageUrls: [String]
    public let challengeNotes: [String]
    public let isJoinable: Bool
    public let status: ChallengeMemberStatus?
    public let progress: Double
    public let usedPoint: Int
    public let earnedPoint: Int
    public let isRecruitmentClosed: Bool  // 서버에서 계산된 값
}

