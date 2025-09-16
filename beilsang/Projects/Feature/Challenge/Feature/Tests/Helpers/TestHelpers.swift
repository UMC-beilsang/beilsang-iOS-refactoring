import Foundation
@testable import ChallengeFeature
import ModelsShared
import ChallengeDomain

extension Challenge {
    static func mock(
        id: String = "test-id",
        title: String = "테스트 챌린지",
        status: String = "RECRUITING",
        isParticipating: Bool = false,
        depositAmount: Int = 1000,
        currentParticipants: Int = 50,
        maxParticipants: Int = 100
    ) -> Challenge {
        Challenge(
            id: id,
            title: title,
            description: "테스트용 챌린지 설명",
            category: "plogging",
            status: status,
            progress: 50.0,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            currentParticipants: currentParticipants,
            maxParticipants: maxParticipants,
            depositAmount: depositAmount,
            certificationMethod: "사진 인증",
            infoImageUrls: [],
            certImageUrls: [],
            thumbnailImageUrl: "test-image",
            isLiked: false,
            likeCount: 10,
            isParticipating: isParticipating,
            createdAt: Date()
        )
    }
}
