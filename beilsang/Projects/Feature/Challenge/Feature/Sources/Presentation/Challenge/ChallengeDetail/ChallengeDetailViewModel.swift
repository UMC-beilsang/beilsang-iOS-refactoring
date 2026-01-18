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
    public let repository: ChallengeRepositoryProtocol
    
    @Published public private(set) var challenge: Challenge?
    @Published public var recommendChallenges: [Challenge] = []
    @Published public var state: ChallengeDetailState = .notEnrolled(.closed)
    @Published public var isLoading: Bool = true
    
    // 피드 관련 상태 
    @Published public var feedThumbnails: [ChallengeFeedThumbnail] = []
    @Published public var showFeedDetail = false
    @Published public var selectedFeedId: Int? = nil
    
    // 팝업 관련 상태
    @Published var showingPopup = false
    @Published var currentPopupType: ChallengePopupType?
    @Published var userPoint: Int = 2500
    @Published var showFeedsDetail = false
    @Published var showFeeds = false
    @Published var showCertification = false
    
    private let fetchDetailUseCase: FetchChallengeDetailUseCaseProtocol
    private let checkEnrollmentUseCase: CheckChallengeEnrollmentUseCaseProtocol
    private let fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    private let fetchFeedThumbnailsUseCase: FetchChallengeFeedThumbnailsUseCaseProtocol
    private let joinChallengeUseCase: JoinChallengeUseCaseProtocol
    
    public init(
        challengeId: Int,
        repository: ChallengeRepositoryProtocol,
        fetchDetailUseCase: FetchChallengeDetailUseCaseProtocol,
        checkEnrollmentUseCase: CheckChallengeEnrollmentUseCaseProtocol,
        fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol,
        fetchFeedThumbnailsUseCase: FetchChallengeFeedThumbnailsUseCaseProtocol,
        joinChallengeUseCase: JoinChallengeUseCaseProtocol
    ) {
        self.challengeId = challengeId
        self.repository = repository
        self.fetchDetailUseCase = fetchDetailUseCase
        self.checkEnrollmentUseCase = checkEnrollmentUseCase
        self.fetchRecommendedChallengesUseCase = fetchRecommendedChallengesUseCase
        self.fetchFeedThumbnailsUseCase = fetchFeedThumbnailsUseCase
        self.joinChallengeUseCase = joinChallengeUseCase
    }
    
    // MARK: - Computed Properties
    public var title: String { challenge?.title ?? "" }
    public var description: String { challenge?.description ?? "" }
    public var category: String { challenge?.category ?? "" }
    public var status: ChallengeMemberStatus? { challenge?.memberStatus }
    public var imageURL: String { challenge?.thumbnailImageUrl ?? "" }
    public var certImages: [String] { challenge?.certImageUrls ?? [] }
    public var startDate: Date { challenge?.startDate ?? Date() }
    public var endDate: Date { challenge?.endDate ?? Date() }
    public var progress: Double { challenge?.progress ?? 0 }
    public var depositAmount: Int { challenge?.depositAmount ?? 0 }
    public var participantText: String { "\(challenge?.currentParticipants ?? 0)명" }
    public var depositText: String { "\(challenge?.depositAmount ?? 0)P" }
    public var createdAtText: String {
        guard let createdAt = challenge?.createdAt else { return "" }
        return DateFormatter.frontFormatter.string(from: createdAt)
    }
    public var dDayText: String {
        guard let start = challenge?.startDate else { return "" }
        return ChallengeDetailViewModel.makeDDayText(from: start)
    }
    
    // MARK: - API
    @MainActor
    public func loadChallengeDetail() async {
        isLoading = true
        
        // 목업 데이터일 때만 최소 0.5초 스켈레톤 UI 표시를 위한 지연
        let shouldDelay = MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
        } : nil
        
        async let fetchTask = Task {
            do {
                // 챌린지 상세 정보 & 참여 여부 확인
                let detail = try await fetchDetailUseCase.execute(challengeId: challengeId)
                let enrollment = try await checkEnrollmentUseCase.execute(challengeId: challengeId)
                
                return (detail, enrollment)
            } catch {
                throw error
            }
        }
        
        do {
            let (detail, enrollment) = try await fetchTask.value
            
            if let delay = delayTask {
                await delay.value // 목업일 때만 최소 0.5초 대기
            }
            
            self.challenge = detail
            self.state = ChallengeDetailViewModel.makeState(
                from: detail,
                isEnrolled: enrollment.isEnrolled
            )
            
            #if DEBUG
            print("✅ Challenge loaded - isEnrolled: \(enrollment.isEnrolled)")
            #endif
        } catch {
            if let delay = delayTask {
                await delay.value // 에러 발생 시에도 목업일 때만 최소 0.5초 대기
            }
            print("❌ 상세 불러오기 실패: \(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    public func loadRecommendedChallenges() async {
        do {
            let challenges = try await fetchRecommendedChallengesUseCase.execute()
            self.recommendChallenges = Array(challenges.prefix(2))
        } catch {
            print("❌ 추천 챌린지 로드 실패: \(error)")
        }
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
    public func loadFeedThumbnails() async {
        do {
            let response = try await fetchFeedThumbnailsUseCase.execute(challengeId: challengeId, page: 1)
            
            self.feedThumbnails = Array(response.feeds.prefix(4))
            
        } catch {
            print("❌ 피드 썸네일 불러오기 실패: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    public func handleCertificationCompleted() {
        if case .enrolled(.inProgress(_)) = state {
            state = .enrolled(.inProgress(canCertify: false))
        }
    }
    
    // MARK: - 팝업 관련 비즈니스 로직
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
        currentPopupType = .report
        showingPopup = true
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
    
    // MARK: - 팝업 액션 처리
    @MainActor
    public func handlePrimaryAction(for popupType: ChallengePopupType) async -> ChallengeActionResult {
        dismissPopup()
        
        switch popupType {
        case .participate:
            return await participateInChallenge()
        case .insufficientPoint:
            return .navigateToPointCharge
        case .report:
            return await reportChallenge()
        case .settlement:
            return .none
        default:
            return .none
        }
    }
    
    // MARK: - Private 메서드
    private func handleParticipateAction() {
        let requiredPoint = depositAmount
        
        if userPoint >= requiredPoint {
            currentPopupType = .participate(
                requiredPoint: requiredPoint,
                currentPoint: userPoint,
                periodText: calculatePeriodText()
            )
        } else {
            currentPopupType = .insufficientPoint(
                required: requiredPoint,
                current: userPoint
            )
        }
        showingPopup = true
    }
    
    private func showSettlementPopup() {
        let remainingSeconds = calculateRemainingSettlementTime()
        currentPopupType = .settlement(secondsRemaining: remainingSeconds)
        showingPopup = true
    }
    
    private func calculatePeriodText() -> String {
        guard let challenge else { return "" }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: challenge.startDate, to: challenge.endDate).day ?? 0
        
        if days <= 7 {
            return "1주일"
        } else if days <= 30 {
            return "1개월"
        } else {
            return "\(days)일"
        }
    }
    
    private func calculateRemainingSettlementTime() -> Int {
        // TODO: 실제 정산 남은 시간 계산 로직
        return 120
    }
    
    @MainActor
    private func participateInChallenge() async -> ChallengeActionResult {
        do {
            try await joinChallengeUseCase.execute(challengeId: challengeId)
            await handleChallengeJoined()
            return .success(message: "챌린지 신청을 완료했어요!")
        } catch {
            #if DEBUG
            print("❌ 챌린지 참여 실패: \(error)")
            #endif
            return .error(message: "챌린지 참여에 실패했습니다.")
        }
    }
    
    @MainActor
    private func reportChallenge() async -> ChallengeActionResult {
        do {
            // try await repository.reportChallenge(challengeId: challengeId)
            return .success(message: "신고가 완료되었습니다")
        } catch {
            return .error(message: "신고 처리에 실패했습니다.")
        }
    }
    
    // MARK: - Static 메서드
    private static func makeState(from challenge: Challenge, isEnrolled: Bool? = nil) -> ChallengeDetailState {
        let now = Date()
        
        // API 응답의 isEnrolled를 우선 사용, 없으면 challenge.isParticipating 사용
        let participating = isEnrolled ?? challenge.isParticipating
        
        if participating {
            // ChallengeMemberStatus 기준으로 판단
            switch challenge.memberStatus {
            case .notYet:
                return .enrolled(.beforeStart)
            case .ongoing:
                let canCertify = now >= challenge.startDate && now <= challenge.endDate
                return .enrolled(.inProgress(canCertify: canCertify))
            case .success:
                return .enrolled(.finished(success: true))
            case .fail:
                return .enrolled(.finished(success: false))
            case .notJoined, .none:
                // 정산 중 (status가 없을 때)
                if now > challenge.endDate {
                    return .enrolled(.calculating)
                } else {
                    return .enrolled(.inProgress(canCertify: true))
                }
            }
        } else {
            // 미참여 상태
            if now > challenge.endDate || challenge.isRecruitmentClosed {
                return .notEnrolled(.closed)
            } else {
                return .notEnrolled(.canApply)
            }
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
    case none
}
