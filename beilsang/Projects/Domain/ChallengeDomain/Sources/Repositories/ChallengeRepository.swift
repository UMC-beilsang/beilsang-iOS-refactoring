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
    func fetchChallengeDetail(challengeId: String) async throws -> Challenge
    func participateInChallenge(challengeId: String) async throws
    func reportChallenge(challengeId: String) async throws
    func fetchChallengeFeedThumbnails(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse
    func fetchChallengeFeedDetail(feedId: Int) async throws -> ChallengeFeedDetail
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
                challengePeriod: "2025.09.01 ~ 2026.09.30",
                currentParticipants: 30,
                maxParticipants: 100,
                depositAmount: 1000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                author: "나지롱",
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
                challengePeriod: "2025.09.05 ~ 2026.10.05",
                currentParticipants: 15,
                maxParticipants: 40,
                depositAmount: 1500,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 20),
                author: "박세영이지롱",
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
                challengePeriod: "2025.09.10 ~ 2026.09.24",
                currentParticipants: 0,
                maxParticipants: 50,
                depositAmount: 2000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 14),
                author: "헤헤",
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
                challengePeriod: "2025.09.02 ~ 2026.09.30",
                currentParticipants: 30,
                maxParticipants: 100,
                depositAmount: 1000,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                author: "플로깅작성자",
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
    
    public func fetchChallengeDetail(challengeId: String) async throws -> Challenge {
            // 일단 Mock에서는 id에 맞는 데이터를 간단히 만들어주자
            switch challengeId {
            case "1":
                return Challenge(
                    id: "1",
                    title: "플로깅",
                    description: "환경을 지키는 첫 걸음, 함께하는 플로깅 챌린지!",
                    category: "plogging",
                    status: "IN_PROGRESS",
                    progress: 30.0,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400 * 30),
                    author: "플로깅작성사..",
                    currentParticipants: 30,
                    maxParticipants: 100,
                    depositAmount: 1000,
                    certificationMethod: "사진 인증",
                    infoImageUrls: ["challengeThumbnail1"],
                    certImageUrls: ["certImage1"],
                    thumbnailImageUrl: "challengeThumbnail1",
                    isLiked: false,
                    likeCount: 77,
                    isParticipating: true,
                    createdAt: Date()
                )
            case "2":
                return Challenge(
                    id: "2",
                    title: "자전거 출퇴근",
                    description: "출퇴근길을 자전거로! 탄소 절감과 건강을 동시에.",
                    category: "bicycle",
                    status: "UPCOMING",
                    progress: 0.0,
                    startDate: Date(),
                    endDate: Date().addingTimeInterval(86400 * 14),
                    author: "멀린멀린",
                    currentParticipants: 0,
                    maxParticipants: 50,
                    depositAmount: 2000,
                    certificationMethod: "GPS 트래킹",
                    infoImageUrls: ["challengeThumbnail1"],
                    certImageUrls: [],
                    thumbnailImageUrl: "challengeThumbnail1",
                    isLiked: true,
                    likeCount: 50,
                    isParticipating: false,
                    createdAt: Date()
                )
            default:
                throw NSError(domain: "MockChallengeRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "챌린지를 찾을 수 없습니다."])
            }
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
    
    //TODO: - 맞춰서 수정
    public func fetchChallengeFeedThumbnails(challengeId: Int, page: Int? = nil) async throws -> ChallengeFeedThumbnailResponse {
        let mockThumbnails: [ChallengeFeedThumbnail] = [
            ChallengeFeedThumbnail(feedId: 1, feedUrl: "challengeThumbnail1", day: 1, isMyFeed: true),
            ChallengeFeedThumbnail(feedId: 2, feedUrl: "challengeThumbnail2", day: 2, isMyFeed: true),
            ChallengeFeedThumbnail(feedId: 3, feedUrl: "challengeThumbnail1", day: 3, isMyFeed: false),
            ChallengeFeedThumbnail(feedId: 4, feedUrl: "challengeThumbnail2", day: 1, isMyFeed: true),
            ChallengeFeedThumbnail(feedId: 5, feedUrl: "challengeThumbnail1", day: 2, isMyFeed: false),
            ChallengeFeedThumbnail(feedId: 6, feedUrl: "challengeThumbnail2", day: 4, isMyFeed: true),
            ChallengeFeedThumbnail(feedId: 7, feedUrl: "challengeThumbnail1", day: 5, isMyFeed: false),
            ChallengeFeedThumbnail(feedId: 8, feedUrl: "challengeThumbnail2", day: 6, isMyFeed: true)
        ]
        
        return ChallengeFeedThumbnailResponse(
            feeds: mockThumbnails,
            hasNext: (page ?? 0) < 2
        )
    }
    
    public func fetchChallengeFeedDetail(feedId: Int) async throws -> ChallengeFeedDetail {
        let isMyFeed = feedId == 1
        
        return ChallengeFeedDetail(
            id: feedId,
            feedUrl: "challengeThumbnail1",
            day: feedId,
            userName: isMyFeed ? "나" : "참여자\(feedId)",
            userProfileImageUrl: "profile1",
            description: "일주일에 한 번씩 길을 걸으며 플로깅을 해보는 건 어떨까요? '우리 가치 플로깅하자'는 챌린저 분들이 함께 활동을 인증하며 플로깅 문화를 확산시키는 챌린지입니다! 여러분의 많은 참여 기대하겠습니다!",
            likeCount: 77,
            isLiked: false,
            challengeTags: ["플로깅", "우리가치플로깅하자"],
            createdAt: Date().addingTimeInterval(-86400 * Double(feedId)),
            isMyFeed: isMyFeed
        )
    }
}
