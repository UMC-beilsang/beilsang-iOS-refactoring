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
    @Published var feedDetail: ChallengeFeedDetail?
    @Published var isLoading = true
    @Published var recommendedChallenges: [Challenge] = []
    @Published var showingPopup = false
    @Published var currentPopupType: ChallengePopupType?

    public let feedId: Int
    public let repository: ChallengeRepositoryProtocol

    public init(feedId: Int, repository: ChallengeRepositoryProtocol) {
        self.feedId = feedId
        self.repository = repository
    }

    // MARK: - Load
    func loadFeedDetail() async {
        isLoading = true
        
        let shouldDelay = MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil

        do {
            feedDetail = try await repository.fetchChallengeFeedDetail(feedId: feedId)
            recommendedChallenges = try await repository.fetchRecommendedChallenges()
            
            if let delay = delayTask {
                await delay.value
            }
        } catch {
            if let delay = delayTask {
                await delay.value
            }
            print("❌ 피드 상세 로딩 실패:", error.localizedDescription)
        }
        
        isLoading = false
    }

    // MARK: - 좋아요 토글
    func toggleLike() async {
        guard var detail = feedDetail else { return }
        
        // UI 먼저 업데이트 (낙관적 업데이트)
        let originalIsLiked = detail.isLiked
        let originalLikeCount = detail.likeCount
        
        detail.isLiked.toggle()
        detail.likeCount += detail.isLiked ? 1 : -1
        feedDetail = detail

        // 서버 반영 (원래 상태를 전달)
        do {
            let result = try await repository.toggleFeedLike(
                feedId: feedId,
                currentlyLiked: originalIsLiked
            )
            
            // 서버 응답으로 정확한 값 업데이트
            detail.isLiked = result.isLiked
            detail.likeCount = result.likeCount
            feedDetail = detail
            
            #if DEBUG
            print("✅ 좋아요 토글 완료 - feedId: \(feedId), isLiked: \(result.isLiked)")
            #endif
        } catch {
            // 실패 시 롤백
            detail.isLiked = originalIsLiked
            detail.likeCount = originalLikeCount
            feedDetail = detail
            
            #if DEBUG
            print("❌ 좋아요 토글 실패: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - 신고 관련
    func showReportPopup() {
        currentPopupType = .report
        showingPopup = true
    }

    func dismissPopup() {
        showingPopup = false
        currentPopupType = nil
    }

    func handleReport() async -> Bool {
        do {
            try await repository.reportChallenge(challengeId: feedId)
            return true
        } catch {
            print("❌ 신고 실패:", error.localizedDescription)
            return false
        }
    }
}
