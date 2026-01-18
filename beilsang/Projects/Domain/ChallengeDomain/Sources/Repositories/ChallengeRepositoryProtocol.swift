//
//  ChallengeRepositoryProtocol.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 10/7/25.
//

import Foundation
import ModelsShared

public protocol ChallengeRepositoryProtocol {
    func fetchActiveChallenges() async throws -> [Challenge]
    func fetchRecommendedChallenges() async throws -> [Challenge]
    func fetchChallengeList(request: ChallengeListRequest) async throws -> [Challenge]
    func fetchChallengeDetail(challengeId: Int) async throws -> Challenge
    func participateInChallenge(challengeId: Int) async throws
    func reportChallenge(challengeId: Int) async throws
    func fetchChallengeFeedThumbnails(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse
    func fetchChallengeFeedDetail(feedId: Int) async throws -> ChallengeFeedDetail
    func fetchHonorsChallenges(by keyword: Keyword) async throws -> [Challenge]
    func fetchKeywordFeeds(by keyword: Keyword, page: Int) async throws -> [ChallengeFeedDetail]
    func createChallenge(request: ChallengeCreateRequest, infoImages: [Data], certImages: [Data]) async throws -> ChallengeCreateResponse
    func fetchFeedList(category: String?, page: Int, size: Int) async throws -> FeedListResponse
    func createFeed(request: FeedCreateRequest) async throws -> FeedCreateData
    func fetchFeedDetailData(feedId: Int) async throws -> FeedDetailData
    func toggleFeedLike(feedId: Int, currentlyLiked: Bool) async throws -> FeedLikeData
    func checkChallengeEnrollment(challengeId: Int) async throws -> ChallengeEnrollmentData
}
