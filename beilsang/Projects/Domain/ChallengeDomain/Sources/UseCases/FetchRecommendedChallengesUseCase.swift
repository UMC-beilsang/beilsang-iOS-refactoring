//  FetchRecommendedChallengesUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol FetchRecommendedChallengesUseCaseProtocol {
    func execute(size: Int) async throws -> [ChallengeItem]
}

public final class FetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol {
    private let repository: ChallengeQueryRepositoryProtocol
    
    public init(repository: ChallengeQueryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(size: Int = 10) async throws -> [ChallengeItem] {
        let request = RecommendedChallengeRequest(size: size)
        return try await repository.fetchRecommended(request: request)
    }
}

