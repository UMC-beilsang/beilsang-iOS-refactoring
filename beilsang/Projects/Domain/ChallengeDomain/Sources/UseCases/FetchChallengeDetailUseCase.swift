//
//  FetchChallengeDetailUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import ModelsShared

public protocol FetchChallengeDetailUseCaseProtocol {
    func execute(challengeId: Int) async throws -> Challenge
}

public final class FetchChallengeDetailUseCase: FetchChallengeDetailUseCaseProtocol {
    private let repository: ChallengeRepositoryProtocol
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(challengeId: Int) async throws -> Challenge {
        try await repository.fetchChallengeDetail(challengeId: challengeId)
    }
}
