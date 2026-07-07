//
//  ChallengeQueryRepositoryProtocol.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared

// 챌린지 조회 전용
public protocol ChallengeQueryRepositoryProtocol {
    func fetchChallengeDetail(challengeId: Int) async throws -> ChallengeDetailData
    func fetchLikedChallenges(request: LikedChallengeListRequest) async throws -> ChallengePageData
    func fetchClosedChallenges(request: ClosedChallengeListRequest) async throws -> ChallengePageData
    func fetchOpenChallenges(request: OpenChallengeListRequest) async throws -> ChallengePageData
    func fetchMyChallenges(request: MyChallengeListRequest) async throws -> ChallengePageData
    
    func fetchRecommended(request: RecommendedChallengeRequest) async throws -> [ChallengeItem]
    func searchClosedChallenges(request: SearchClosedChallengeRequest) async throws -> ChallengePageData
    func searchOpenChallenges(request: SearchOpenChallengeRequest) async throws -> ChallengePageData
    
    func checkChallengeEnrollment(challengeId: Int) async throws -> ChallengeEnrollmentData
    
    // TODO: API 미구현 - challengeId로 피드 썸네일 조회
    func fetchChallengeFeedThumbnails(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse
}

