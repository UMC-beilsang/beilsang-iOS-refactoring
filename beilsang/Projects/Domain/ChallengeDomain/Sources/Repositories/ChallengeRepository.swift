//
//  ChallengeRepository.swift (Facade)
//  ChallengeDomain
//
//  Refactored by Seyoung Park on 12/26/25.
//  Original implementation분 분리된 Impl 파일들로 이동
//

import Foundation
import ModelsShared
import NetworkCore

/// Facade Pattern: 기존 인터페이스 유지하면서 내부 구현을 분리된 Repository들로 위임
public final class ChallengeRepository: ChallengeRepositoryProtocol {
    private let queryRepo: ChallengeQueryRepositoryProtocol
    private let commandRepo: ChallengeCommandRepositoryProtocol
    private let feedRepo: FeedRepositoryProtocol
    
    // MARK: - Init
    public init(baseURL: String) {
        let apiClient = APIClient(baseURL: baseURL)
        self.queryRepo = ChallengeQueryRepoImpl(apiClient: apiClient)
        self.commandRepo = ChallengeCommandRepoImpl(apiClient: apiClient)
        self.feedRepo = FeedRepoImpl(apiClient: apiClient)
    }
    
    public init(apiClient: APIClientProtocol) {
        self.queryRepo = ChallengeQueryRepoImpl(apiClient: apiClient)
        self.commandRepo = ChallengeCommandRepoImpl(apiClient: apiClient)
        self.feedRepo = FeedRepoImpl(apiClient: apiClient)
    }
    
    // MARK: - Query Methods (위임)
    public func fetchActiveChallenges() async throws -> [Challenge] {
        try await queryRepo.fetchActiveChallenges()
    }
    
    public func fetchRecommendedChallenges() async throws -> [Challenge] {
        try await queryRepo.fetchRecommendedChallenges()
    }
    
    public func fetchChallengeList(request: ChallengeListRequest) async throws -> [Challenge] {
        try await queryRepo.fetchChallengeList(request: request)
    }
    
    public func fetchChallengeDetail(challengeId: Int) async throws -> Challenge {
        try await queryRepo.fetchChallengeDetail(challengeId: challengeId)
    }
    
    public func fetchChallengeFeedThumbnails(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse {
        try await queryRepo.fetchChallengeFeedThumbnails(challengeId: challengeId, page: page)
    }
    
    public func fetchChallengeFeedDetail(feedId: Int) async throws -> ChallengeFeedDetail {
        try await feedRepo.fetchChallengeFeedDetail(feedId: feedId)
    }
    
    public func fetchHonorsChallenges(by keyword: Keyword) async throws -> [Challenge] {
        try await queryRepo.fetchHonorsChallenges(by: keyword)
    }
    
    public func fetchKeywordFeeds(by keyword: Keyword, page: Int) async throws -> [ChallengeFeedDetail] {
        try await queryRepo.fetchKeywordFeeds(by: keyword, page: page)
    }
    
    public func checkChallengeEnrollment(challengeId: Int) async throws -> ChallengeEnrollmentData {
        try await queryRepo.checkChallengeEnrollment(challengeId: challengeId)
    }
    
    // MARK: - Command Methods (위임)
    public func participateInChallenge(challengeId: Int) async throws {
        try await commandRepo.participateInChallenge(challengeId: challengeId)
    }
    
    public func reportChallenge(challengeId: Int) async throws {
        try await commandRepo.reportChallenge(challengeId: challengeId)
    }
    
    public func createChallenge(request: ChallengeCreateRequest, infoImages: [Data], certImages: [Data]) async throws -> ChallengeCreateResponse {
        try await commandRepo.createChallenge(request: request, infoImages: infoImages, certImages: certImages)
    }
    
    // MARK: - Feed Methods (위임)
    public func fetchFeedList(category: String?, page: Int, size: Int) async throws -> FeedListResponse {
        try await feedRepo.fetchFeedList(category: category, page: page, size: size)
    }
    
    public func createFeed(request: FeedCreateRequest) async throws -> FeedCreateData {
        try await feedRepo.createFeed(request: request)
    }
    
    public func fetchFeedDetailData(feedId: Int) async throws -> FeedDetailData {
        try await feedRepo.fetchFeedDetailData(feedId: feedId)
    }
    
    public func toggleFeedLike(feedId: Int, currentlyLiked: Bool) async throws -> FeedLikeData {
        try await feedRepo.toggleFeedLike(feedId: feedId, currentlyLiked: currentlyLiked)
    }
}

