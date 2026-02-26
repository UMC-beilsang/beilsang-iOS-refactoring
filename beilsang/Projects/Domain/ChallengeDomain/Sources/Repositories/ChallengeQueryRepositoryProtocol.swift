//
//  ChallengeQueryRepositoryProtocol.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared

/// 챌린지 조회 전용 Repository
public protocol ChallengeQueryRepositoryProtocol {
    func fetchActiveChallenges() async throws -> [Challenge]
    func fetchRecommendedChallenges() async throws -> [Challenge]
    func fetchChallengeList(request: ChallengeListRequest) async throws -> [Challenge]
    func fetchChallengeDetail(challengeId: Int) async throws -> Challenge
    func fetchChallengeFeedThumbnails(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse
    func fetchHonorsChallenges(by keyword: Keyword) async throws -> [Challenge]
    func fetchKeywordFeeds(by keyword: Keyword, page: Int) async throws -> [ChallengeFeedDetail]
    func checkChallengeEnrollment(challengeId: Int) async throws -> ChallengeEnrollmentData
}

