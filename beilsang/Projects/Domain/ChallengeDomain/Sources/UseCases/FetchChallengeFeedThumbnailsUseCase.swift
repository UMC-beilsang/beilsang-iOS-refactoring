//
//  FetchChallengeFeedThumbnailsUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol FetchChallengeFeedThumbnailsUseCaseProtocol {
    func execute(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse
}

public final class FetchChallengeFeedThumbnailsUseCase: FetchChallengeFeedThumbnailsUseCaseProtocol {
    private let repository: ChallengeQueryRepositoryProtocol
    
    public init(repository: ChallengeQueryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(challengeId: Int, page: Int? = nil) async throws -> ChallengeFeedThumbnailResponse {
        // TODO: API 미구현 - challengeId로 피드 조회하는 엔드포인트 없음
        // 백엔드 API 추가되면 구현
        try await repository.fetchChallengeFeedThumbnails(challengeId: challengeId, page: page)
    }
}


