//
//  MockChallengeData.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared

public struct MockChallengeData {
    public static let challenges: [Challenge] = [
        Challenge(
            id: 1,
            title: "플로깅",
            description: "환경을 지키는 첫 걸음, 함께하는 플로깅 챌린지!",
            category: "plogging",
            memberStatus: .ongoing,
            progress: 30.0,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            author: "나지롱",
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
            isRecruitmentClosed: false,
            createdAt: Date()
        ),
        Challenge(
            id: 2,
            title: "자전거 출퇴근",
            description: "출퇴근길을 자전거로! 탄소 절감과 건강을 동시에.",
            category: "bicycle",
            memberStatus: .notYet,
            progress: 0.0,
            startDate: Date().addingTimeInterval(86400 * 7),
            endDate: Date().addingTimeInterval(86400 * 21),
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
            isRecruitmentClosed: false,
            createdAt: Date()
        ),
        Challenge(
            id: 3,
            title: "등산 인증",
            description: "매주 산에 오르며 건강을 챙겨보세요.",
            category: "hiking",
            memberStatus: .ongoing,
            progress: 50.0,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 20),
            author: "박세영이지롱",
            currentParticipants: 15,
            maxParticipants: 40,
            depositAmount: 1500,
            certificationMethod: "사진 인증",
            infoImageUrls: ["challengeThumbnail2"],
            certImageUrls: ["certImage1"],
            thumbnailImageUrl: "challengeThumbnail2",
            isLiked: true,
            likeCount: 43,
            isParticipating: false,
            isRecruitmentClosed: false,
            createdAt: Date()
        ),
        // NOTE: Mock 데이터는 최소화 (실제로는 더 많은 데이터를 원하면 추가)
    ]
}

