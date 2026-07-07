//
//  FeedRepositoryProtocol.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared

public protocol FeedRepositoryProtocol {
    func fetchFeedList(category: String?, page: Int, size: Int) async throws -> FeedListResponse
    func fetchMyFeeds(category: String?, page: Int, size: Int) async throws -> FeedListResponse
    func fetchMemberFeeds(memberId: Int, page: Int, size: Int) async throws -> FeedListResponse
    func searchFeeds(keyword: String, sortType: String, category: String?, page: Int, size: Int) async throws -> SearchFeedPageData
    func createFeed(request: FeedCreateRequest, feedImage: Data?) async throws -> FeedCreateData
    func fetchFeedDetailData(feedId: Int) async throws -> FeedDetailData
    func toggleFeedLike(feedId: Int, currentlyLiked: Bool) async throws -> FeedLikeData
    func reportFeed(feedId: Int, reason: String, detail: String?) async throws
}
