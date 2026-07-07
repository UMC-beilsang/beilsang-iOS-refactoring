//
//  ChallengeFeedDetailViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/16/25.
//

import SwiftUI
import ChallengeDomain
import ModelsShared
import UtilityShared

@MainActor
public final class ChallengeFeedDetailViewModel: ObservableObject {
    @Published var feedDetail: FeedDetailData?
    @Published var isLoading = true
    @Published var recommendedChallenges: [ChallengeItem] = []
    @Published var showingPopup = false
    @Published var currentPopupType: ChallengePopupType?
    @Published var showReportSheet = false

    public let feedId: Int
    private let feedRepo: FeedRepositoryProtocol
    private let queryRepo: ChallengeQueryRepositoryProtocol
    private let commandRepo: ChallengeCommandRepositoryProtocol

    public init(
        feedId: Int,
        feedRepo: FeedRepositoryProtocol,
        queryRepo: ChallengeQueryRepositoryProtocol,
        commandRepo: ChallengeCommandRepositoryProtocol
    ) {
        self.feedId = feedId
        self.feedRepo = feedRepo
        self.queryRepo = queryRepo
        self.commandRepo = commandRepo
    }

    func loadFeedDetail() async {
        isLoading = true
        do {
            async let detail = feedRepo.fetchFeedDetailData(feedId: feedId)
            async let items = queryRepo.fetchRecommended(request: RecommendedChallengeRequest(size: 10))
            let (d, i) = try await (detail, items)
            feedDetail = d
            recommendedChallenges = i
        } catch {
            print("❌ 피드 상세 로딩 실패:", error.localizedDescription)
        }
        isLoading = false
    }

    func toggleLike() async {
        guard var detail = feedDetail else { return }
        let originalIsLiked = detail.isLiked
        let originalLikeCount = detail.likeCount
        
        detail.isLiked.toggle()
        detail.likeCount += detail.isLiked ? 1 : -1
        feedDetail = detail

        do {
            let result = try await feedRepo.toggleFeedLike(feedId: feedId, currentlyLiked: originalIsLiked)
            detail.isLiked = result.isLiked
            detail.likeCount = result.likeCount
            feedDetail = detail
        } catch {
            detail.isLiked = originalIsLiked
            detail.likeCount = originalLikeCount
            feedDetail = detail
        }
    }

    func showReportPopup() {
        showReportSheet = true
    }

    func dismissPopup() {
        showingPopup = false
        currentPopupType = nil
    }

    func reportFeedFromSheet(reason: FeedReportReason, otherText: String?) async -> ChallengeActionResult {
        showReportSheet = false
        do {
            let detail = reason.isOther ? otherText : nil
            try await feedRepo.reportFeed(feedId: feedId, reason: reason.apiKey, detail: detail)
            return .success(message: "신고가 접수되었어요")
        } catch ChallengeError.serverError(let message) {
            return .error(message: message)
        } catch {
            return .error(message: "신고 처리 중 오류가 발생했습니다")
        }
    }
}
