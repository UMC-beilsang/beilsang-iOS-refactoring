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
    public let repository: ChallengeRepositoryProtocol
    public let challengeId: String
    
    @Published public private(set) var challenge: Challenge?
    @Published public var recommendChallenges: [Challenge] = []
    @Published public var state: ChallengeDetailState = .notEnrolled(.closed)
    
    // 팝업 관련 상태
    @Published var showingPopup = false
    @Published var currentPopupType: ChallengePopupType?
    @Published var userPoint: Int = 2500
    @Published var showFeeds = false
    @Published var showCertification = false
    
    public init(challengeId: String, repository: ChallengeRepositoryProtocol) {
        self.challengeId = challengeId
        self.repository = repository
    }
    
    // MARK: - Computed Properties
    public var title: String { challenge?.title ?? "" }
    public var description: String { challenge?.description ?? "" }
    public var category: String { challenge?.category ?? "" }
    public var status: String { challenge?.status ?? "" }
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
        return DateFormatter.koreanDate.string(from: createdAt)
    }
    public var dDayText: String {
        guard let start = challenge?.startDate else { return "" }
        return ChallengeDetailViewModel.makeDDayText(from: start)
    }
    
    // MARK: - API
    @MainActor
    public func loadChallengeDetail() async {
        do {
            let detail = try await repository.fetchChallengeDetail(challengeId: challengeId)
            self.challenge = detail
            self.state = ChallengeDetailViewModel.makeState(from: detail)
        } catch {
            print("❌ 상세 불러오기 실패: \(error)")
        }
    }
    
    @MainActor
    public func loadRecommendedChallenges() async {
        do {
            let challenges = try await repository.fetchRecommendedChallenges()
            self.recommendChallenges = challenges
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
            // try await repository.participateInChallenge(challengeId: challengeId)
            await handleChallengeJoined()
            return .success(message: "챌린지 신청을 완료했어요!")
        } catch {
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
    private static func makeState(from challenge: Challenge) -> ChallengeDetailState {
        let now = Date()
        
        if challenge.isParticipating {
            switch challenge.status.uppercased() {
            case "RECRUITING", "WAITING":
                return .enrolled(.beforeStart)
            case "IN_PROGRESS", "ONGOING":
                let canCertify = now >= challenge.startDate && now <= challenge.endDate
                return .enrolled(.inProgress(canCertify: canCertify))
            case "CALCULATING", "SETTLEMENT":
                return .enrolled(.calculating)
            case "ENDED_SUCCESS", "ENDED_FAILURE", "FINISHED", "COMPLETED":
                let success = challenge.status == "ENDED_SUCCESS" || challenge.progress >= 100.0
                return .enrolled(.finished(success: success))
            default:
                return .enrolled(.beforeStart)
            }
        } else {
            switch challenge.status.uppercased() {
            case "RECRUITING":
                if now > challenge.endDate || challenge.currentParticipants >= challenge.maxParticipants {
                    return .notEnrolled(.closed)
                } else {
                    return .notEnrolled(.canApply)
                }
            case "APPLIED", "PENDING":
                return .notEnrolled(.applied)
            default:
                return .notEnrolled(.closed)
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
