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
    private let repository: ChallengeRepositoryProtocol
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(challengeId: Int, page: Int? = nil) async throws -> ChallengeFeedThumbnailResponse {
        try await repository.fetchChallengeFeedThumbnails(challengeId: challengeId, page: page)
    }
}


