//
//  ChallengeFeedDetailViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/16/25.
//

import SwiftUI
import ChallengeDomain
import ModelsShared

@MainActor
class ChallengeFeedDetailViewModel: ObservableObject {
    @Published var feedDetail: ChallengeFeedDetail?
    @Published var isLoading = false
    @Published var recommendedChallenges: [Challenge] = []
    @Published var showingPopup = false
    @Published var currentPopupType: ChallengePopupType?
    
    private let feedId: Int
    private let repository: ChallengeRepositoryProtocol
    
    init(feedId: Int, repository: ChallengeRepositoryProtocol) {
        self.feedId = feedId
        self.repository = repository
    }
    
    func loadFeedDetail() async {
        isLoading = true
        do {
            feedDetail = try await repository.fetchChallengeFeedDetail(feedId: feedId)
            recommendedChallenges = try await repository.fetchRecommendedChallenges()
        } catch {
            print("피드 상세 로딩 실패: \(error)")
        }
        isLoading = false
    }
    
    func toggleLike() async {
        // 좋아요 토글 로직
    }
    func showReportPopup() {
        currentPopupType = .certify
        showingPopup = true
    }
    
    // 팝업 닫기
    func dismissPopup() {
        showingPopup = false
        currentPopupType = nil
    }
    
    // 신고 처리
    func handleReport() async -> Bool {
        do {
            // Repository에 신고 API 호출 (feedId를 String으로 변환)
            try await repository.reportChallenge(challengeId: "\(feedId)")
            return true
        } catch {
            print("신고 실패: \(error)")
            return false
        }
    }
}
