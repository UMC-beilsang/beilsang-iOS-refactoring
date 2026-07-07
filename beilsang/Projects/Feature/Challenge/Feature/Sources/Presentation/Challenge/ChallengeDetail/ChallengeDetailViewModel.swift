//
//  ChallengeDetailViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/3/25.
//

import SwiftUI
import ChallengeDomain
import UtilityShared
import ModelsShared
import UIComponentsShared

public final class ChallengeDetailViewModel: ObservableObject {
    public let challengeId: Int
    
    @Published public private(set) var challenge: ChallengeDetailData?
    @Published public var recommendChallenges: [ChallengeItem] = []
    @Published public var state: ChallengeDetailState = .notEnrolled(.closed)
    @Published public var isLoading: Bool = true
    @Published public var feedThumbnails: [ChallengeFeedThumbnail] = []
    @Published public var showFeedDetail = false
    @Published public var selectedFeedId: Int? = nil
    @Published var showingPopup = false
    @Published var currentPopupType: ChallengePopupType?
    @Published var showReportSheet = false
    @Published var userPoint: Int = 2500
    @Published var showFeedsDetail = false
    @Published var showFeeds = false
    @Published var showCertification = false
    
    public var dDayText: String {
        guard let challenge = challenge else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: challenge.startDate) ?? Date()
        return Self.makeDDayText(from: startDate)
    }
    
    private let fetchDetailUseCase: FetchChallengeDetailUseCaseProtocol
    private let checkEnrollmentUseCase: CheckChallengeEnrollmentUseCaseProtocol
    private let fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    private let fetchFeedThumbnailsUseCase: FetchChallengeFeedThumbnailsUseCaseProtocol
    private let joinChallengeUseCase: JoinChallengeUseCaseProtocol
    
    public let queryRepo: ChallengeQueryRepositoryProtocol
    public let feedRepo: FeedRepositoryProtocol
    public let commandRepo: ChallengeCommandRepositoryProtocol
    
    public init(
        challengeId: Int,
        fetchDetailUseCase: FetchChallengeDetailUseCaseProtocol,
        checkEnrollmentUseCase: CheckChallengeEnrollmentUseCaseProtocol,
        fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol,
        fetchFeedThumbnailsUseCase: FetchChallengeFeedThumbnailsUseCaseProtocol,
        joinChallengeUseCase: JoinChallengeUseCaseProtocol,
        queryRepo: ChallengeQueryRepositoryProtocol,
        feedRepo: FeedRepositoryProtocol,
        commandRepo: ChallengeCommandRepositoryProtocol
    ) {
        self.challengeId = challengeId
        self.fetchDetailUseCase = fetchDetailUseCase
        self.checkEnrollmentUseCase = checkEnrollmentUseCase
        self.fetchRecommendedChallengesUseCase = fetchRecommendedChallengesUseCase
        self.fetchFeedThumbnailsUseCase = fetchFeedThumbnailsUseCase
        self.joinChallengeUseCase = joinChallengeUseCase
        self.queryRepo = queryRepo
        self.feedRepo = feedRepo
        self.commandRepo = commandRepo
    }
    
    // MARK: - Toggle Like
    @MainActor
    public func toggleLike() async {
        guard var current = challenge else { return }
        let originalIsLiked = current.isLiked
        let originalLikeCount = current.likeCount
        
        current.isLiked = !originalIsLiked
        current.likeCount += originalIsLiked ? -1 : 1
        challenge = current
        
        do {
            if originalIsLiked {
                try await commandRepo.unlikeChallenge(challengeId: challengeId)
            } else {
                try await commandRepo.likeChallenge(challengeId: challengeId)
            }
        } catch {
            current.isLiked = originalIsLiked
            current.likeCount = originalLikeCount
            challenge = current
        }
    }
    
    // MARK: - API
    @MainActor
    public func loadChallengeDetail() async {
        isLoading = true
        do {
            async let detail = fetchDetailUseCase.execute(challengeId: challengeId)
            async let enrollment = checkEnrollmentUseCase.execute(challengeId: challengeId)
            let (d, e) = try await (detail, enrollment)
            self.challenge = d
            self.state = ChallengeDetailState.make(from: d, enrollment: e)
        } catch {
            print("❌ 상세 불러오기 실패: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    public func loadRecommendedChallenges() async {
        do {
            let challenges = try await fetchRecommendedChallengesUseCase.execute(size: 10)
            self.recommendChallenges = Array(challenges.prefix(2))
        } catch {
            print("❌ 추천 챌린지 로드 실패: \(error)")
        }
    }
    
    @MainActor
    public func loadFeedThumbnails() async {
        self.feedThumbnails = []
    }
    
    @MainActor
    public func updateTodayCertificationStatus(completed: Bool) {
        if case .enrolled(.inProgress(_)) = state {
            state = .enrolled(.inProgress(canCertify: !completed))
        }
    }
    
    @MainActor
    public func handleChallengeJoined() {
        state = .enrolled(.beforeStart)
    }
    
    @MainActor
    public func handleCertificationCompleted() {
        if case .enrolled(.inProgress(_)) = state {
            state = .enrolled(.inProgress(canCertify: false))
        }
    }
    
    public func handleMainAction() {
        switch state {
        case .notEnrolled(.canApply):
            handleParticipateAction()
        case .enrolled(.calculating):
            showSettlementPopup()
        default:
            break
        }
    }
    
    public func showReportPopup() {
        showReportSheet = true
    }
    
    public func dismissPopup() {
        showingPopup = false
        currentPopupType = nil
    }
    
    public func showFeedDetail(feedId: Int) {
        selectedFeedId = feedId
        showFeedDetail = true
    }
    public func showFeedGallery() { showFeeds = true }
    public func dismissFeedGallery() { showFeeds = false }
    public func showCert() { showCertification = true }
    public func dismissCert() { showCertification = false }
    
    @MainActor
    public func handlePrimaryAction(for popupType: ChallengePopupType) async -> ChallengeActionResult {
        dismissPopup()
        switch popupType {
        case .participate: return await participateInChallenge()
        case .insufficientPoint: return .navigateToPointCharge
        default: return .none
        }
    }
    
    private func handleParticipateAction() {
        guard let challenge = challenge else { return }
        let requiredPoint = challenge.joinPoint
        if userPoint >= requiredPoint {
            currentPopupType = .participate(
                requiredPoint: requiredPoint,
                currentPoint: userPoint,
                periodText: calculatePeriodText()
            )
        } else {
            currentPopupType = .insufficientPoint(required: requiredPoint, current: userPoint)
        }
        showingPopup = true
    }
    
    private func showSettlementPopup() {
        currentPopupType = .settlement(secondsRemaining: 120)
        showingPopup = true
    }
    
    private func calculatePeriodText() -> String {
        guard let challenge else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let start = formatter.date(from: challenge.startDate),
              let end = formatter.date(from: challenge.finishDate) else { return "" }
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        if days <= 7 { return "1주일" }
        else if days <= 30 { return "1개월" }
        else { return "\(days)일" }
    }
    
    @MainActor
    public func reportChallengeFromSheet(reason: ChallengeReportReason, otherText: String?) async -> ChallengeActionResult {
        let detail: String? = reason == .other ? otherText?.trimmingCharacters(in: .whitespaces) : nil
        do {
            try await commandRepo.reportChallenge(challengeId: challengeId, reason: reason.apiKey, detail: detail)
            return .success(message: "신고가 접수되었어요")
        } catch ChallengeError.serverError(let message) {
            return .error(message: message)
        } catch {
            return .error(message: "신고 처리 중 오류가 발생했습니다")
        }
    }

    @MainActor
    private func participateInChallenge() async -> ChallengeActionResult {
        do {
            try await joinChallengeUseCase.execute(challengeId: challengeId)
            await handleChallengeJoined()
            return .success(message: "챌린지 신청을 완료했어요!")
        } catch {
            return .error(message: "챌린지 참여에 실패했습니다.")
        }
    }
    
    private static func makeDDayText(from startDate: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: startDate)
        let components = calendar.dateComponents([.day], from: today, to: start)
        guard let days = components.day else { return "" }
        if days == 0 { return "D-DAY" }
        else if days > 0 { return "D-\(days)" }
        else { return "D+\(-days)" }
    }
}

// MARK: - Supporting Types
public enum ChallengeActionResult {
    case success(message: String)
    case error(message: String)
    case navigateToPointCharge
    case openWebView(url: String)
    case none
}
