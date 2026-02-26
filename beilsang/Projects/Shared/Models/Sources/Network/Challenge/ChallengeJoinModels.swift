//
//  ChallengeJoinModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Response
public typealias ChallengeJoinResponse = APIResponse<ChallengeJoinData>

public struct ChallengeJoinData: Codable, Sendable {
    public let challengeId: Int
    public let memberId: Int
    public let joinDate: String // ISO 8601 format
    public let remainingPoint: Int
}

