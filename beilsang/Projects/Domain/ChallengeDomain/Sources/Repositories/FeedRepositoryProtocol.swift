//
//  FeedRepositoryProtocol.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared

/// 피드 관련 Repository
public protocol FeedRepositoryProtocol {
    func fetchFeedList(category: String?, page: Int, size: Int) async throws -> FeedListResponse
    func createFeed(request: FeedCreateRequest) async throws -> FeedCreateData
    func fetchFeedDetailData(feedId: Int) async throws -> FeedDetailData
    func fetchChallengeFeedDetail(feedId: Int) async throws -> ChallengeFeedDetail
    func toggleFeedLike(feedId: Int, currentlyLiked: Bool) async throws -> FeedLikeData
}

