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
    private let repository: ChallengeRepositoryProtocol
    private let challenge: Challenge
    
    @Published var title: String
    @Published var description: String
    @Published var category: String
    @Published var status: String
    @Published var imageURL: String
    @Published var certImages: [String]
    @Published var periodText: String
    @Published var startDateText: String
    @Published var dDayText: String
    @Published var participantText: String
    @Published var depositText: String
    @Published var createdAtText: String
    @Published var isLiked: Bool
    @Published var likeCount: Int
    @Published var recommendChallenges: [Challenge] = []
    @Published var state: ChallengeDetailState
    
    // 팝업 관련 상태
    @Published var showingPopup = false
    @Published var currentPopupType: ChallengePopupType?
    @Published var userPoint: Int = 2500 // TODO: 실제 사용자 포인트로 교체
    
    public var startDate: Date { challenge.startDate }
    public var progress: Double { challenge.progress }
    public var depositAmount: Int { challenge.depositAmount }
    
    public init(challenge: Challenge, repository: ChallengeRepositoryProtocol) {
        self.repository = repository
        self.challenge = challenge
        
        self.title = challenge.title
        self.description = challenge.description
        self.category = challenge.category
        self.status = challenge.status
        self.imageURL = challenge.thumbnailImageUrl ?? ""
        self.certImages = challenge.certImageUrls
        
        let formatter = DateFormatter.koreanDate
        let weekFormatter = DateFormatter.koreanDateWithWeekday
        self.periodText = "\(formatter.string(from: challenge.startDate)) ~ \(formatter.string(from: challenge.endDate))"
        
        self.startDateText = weekFormatter.string(from: challenge.startDate)
        self.dDayText = ChallengeDetailViewModel.makeDDayText(from: challenge.startDate)
        
        self.participantText = "\(challenge.currentParticipants)명"
        self.depositText = "\(challenge.depositAmount)P"
        
        self.createdAtText = formatter.string(from: challenge.createdAt)
        
        self.likeCount = challenge.likeCount
        self.isLiked = challenge.isLiked
        
        self.recommendChallenges = []
        
        self.state = ChallengeDetailViewModel.makeState(from: challenge)
    }
    
    // MARK: - 기존 메서드들
    
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
    
    // MARK: - Private 메서드들
    
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
            // TODO: 실제 API 호출로 교체
            // try await repository.participateInChallenge(challengeId: challenge.id)
            
            // 성공 시 상태 업데이트
            await handleChallengeJoined()
            return .success(message: "챌린지 신청을 완료했어요!")
        } catch {
            return .error(message: "챌린지 참여에 실패했습니다.")
        }
    }
    
    @MainActor
    private func reportChallenge() async -> ChallengeActionResult {
        do {
            // TODO: 실제 API 호출로 교체
            // try await repository.reportChallenge(challengeId: challenge.id)
            
            return .success(message: "신고가 완료되었습니다")
        } catch {
            return .error(message: "신고 처리에 실패했습니다.")
        }
    }
    
    // MARK: - Static 메서드들
    
    private static func makeState(from challenge: Challenge) -> ChallengeDetailState {
        let now = Date()
        
        if challenge.isParticipating {
            switch challenge.status.uppercased() {
            case "RECRUITING", "WAITING":
                return .enrolled(.beforeStart)
                
            case "IN_PROGRESS", "ONGOING":
                let canCertify = now >= challenge.startDate && now <= challenge.endDate
                return .enrolled(.inProgress(canCertify: false))
                
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
        
        if days == 0 {
            return "D-DAY"
        } else if days > 0 {
            return "D-\(days)"
        } else {
            return "D+\(-days)"
        }
    }
}

// MARK: - Supporting Types

public enum ChallengeActionResult {
    case success(message: String)
    case error(message: String)
    case navigateToPointCharge
    case none
}
