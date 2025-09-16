//
//  ChallengeRepository.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 9/2/25.
//

import Foundation
import ModelsShared

public protocol ChallengeRepositoryProtocol {
    func fetchActiveChallenges() async throws -> [Challenge]
    func fetchRecommendedChallenges() async throws -> [Challenge]
    func participateInChallenge(challengeId: String) async throws
    func reportChallenge(challengeId: String) async throws
}

public final class MockChallengeRepository: ChallengeRepositoryProtocol {
    
    public init() {}
    
    public func fetchActiveChallenges() async throws -> [Challenge] {
        let responses: [ChallengeResponse] = [
            ChallengeResponse(
                challengeId: "1",
                title: "플로깅",
                description: "환경을 지키는 첫 걸음, 함께하는 플로깅 챌린지!",
                category: "plogging",
                status: "IN_PROGRESS",
                progress: 30.0,
                challengePeriod: "2025.09.01 ~ 2025.09.30",
                currentParticipants: 30,
                maxParticipants: 100,
                depositAmount: 1000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                certificationMethod: "사진 인증",
                infoImageUrls: ["challengeThumbnail1"],
                certImageUrls: ["certImage1"],
                isLiked: false,
                likeCount: 77,
                isParticipating: true,
                createdAt: Date()
            ),
            ChallengeResponse(
                challengeId: "3",
                title: "등산 인증",
                description: "매주 산에 오르며 건강을 챙겨보세요.",
                category: "hiking",
                status: "IN_PROGRESS",
                progress: 50.0,
                challengePeriod: "2025.09.05 ~ 2025.10.05",
                currentParticipants: 15,
                maxParticipants: 40,
                depositAmount: 1500,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 20),
                certificationMethod: "사진 인증",
                infoImageUrls: ["challengeThumbnail2"],
                certImageUrls: ["certImage2"],
                isLiked: true,
                likeCount: 43,
                isParticipating: false,
                createdAt: Date()
            )
        ]
        return responses.map { Challenge(from: $0) }
    }
    
    public func fetchRecommendedChallenges() async throws -> [Challenge] {
        let responses: [ChallengeResponse] = [
            ChallengeResponse(
                challengeId: "2",
                title: "자전거 출퇴근",
                description: "출퇴근길을 자전거로! 탄소 절감과 건강을 동시에.",
                category: "bicycle",
                status: "UPCOMING",
                progress: 0.0,
                challengePeriod: "2025.09.10 ~ 2025.09.24",
                currentParticipants: 0,
                maxParticipants: 50,
                depositAmount: 2000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 14),
                certificationMethod: "GPS 트래킹",
                infoImageUrls: ["challengeThumbnail1"],
                certImageUrls: [],
                isLiked: true,
                likeCount: 50,
                isParticipating: false,
                createdAt: Date()
            ),
            ChallengeResponse(
                challengeId: "4",
                title: "플로깅",
                description: "길거리 쓰레기를 주우며 함께 달려요.",
                category: "plogging",
                status: "IN_PROGRESS",
                progress: 10.0,
                challengePeriod: "2025.09.02 ~ 2025.09.30",
                currentParticipants: 30,
                maxParticipants: 100,
                depositAmount: 1000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                certificationMethod: "사진 인증",
                infoImageUrls: ["challengeThumbnail2"],
                certImageUrls: [],
                isLiked: false,
                likeCount: 56,
                isParticipating: false,
                createdAt: Date()
            )
        ]
        return responses.map { Challenge(from: $0) }
    }
    
    // 새로 추가된 메서드들
    public func participateInChallenge(challengeId: String) async throws {
        // 실제 구현은 나중에 - 지금은 성공한다고 가정
        print("Mock: 챌린지 \(challengeId) 참여 완료")
    }
    
    public func reportChallenge(challengeId: String) async throws {
        // 실제 구현은 나중에 - 지금은 성공한다고 가정
        print("Mock: 챌린지 \(challengeId) 신고 완료")
    }
}
