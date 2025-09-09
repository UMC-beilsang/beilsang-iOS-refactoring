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

public final class ChallengeDetailViewModel: ObservableObject {
    private let repository: ChallengeRepositoryProtocol
    
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
    
    public init(challenge: Challenge, repository: ChallengeRepositoryProtocol) {
        self.repository = repository
        
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
    
    @MainActor
        public func loadRecommendedChallenges() async {
            do {
                let challenges = try await repository.fetchRecommendedChallenges()
                self.recommendChallenges = challenges
            } catch {
                print("❌ 추천 챌린지 로드 실패: \(error)")
            }
        }
    
    // TODO: - 서버 값 따라 수정
    private static func makeState(from challenge: Challenge) -> ChallengeDetailState {
        let now = Date()
        
        if challenge.isParticipating {
            if now < challenge.startDate {
                return .enrolled(.beforeStart)
            } else if now >= challenge.startDate && now <= challenge.endDate {
                // TODO: 오늘 인증 여부 서버 값 필요
                return .enrolled(.inProgress(canCertify: true))
            } else {
                // TODO: 성공/실패 여부 서버 값 필요 → status 활용
                let success = challenge.status == "ENDED_SUCCESS"
                return .enrolled(.finished(success: success))
            }
        } else {
            if challenge.currentParticipants >= challenge.maxParticipants {
                return .notEnrolled(.closed)
            } else if now <= challenge.startDate {
                return .notEnrolled(.canApply)
            } else {
                return .notEnrolled(.applied)
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
               return "D+\(-days)" // 이미 시작된 경우
           }
       }
}
