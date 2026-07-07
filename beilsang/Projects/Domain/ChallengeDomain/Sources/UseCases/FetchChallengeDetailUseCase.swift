//
//  FetchChallengeDetailUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import ModelsShared

public protocol FetchChallengeDetailUseCaseProtocol {
    func execute(challengeId: Int) async throws -> ChallengeDetailData
}

public final class FetchChallengeDetailUseCase: FetchChallengeDetailUseCaseProtocol {
    private let repository: ChallengeQueryRepositoryProtocol
    
    public init(repository: ChallengeQueryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(challengeId: Int) async throws -> ChallengeDetailData {
        try await repository.fetchChallengeDetail(challengeId: challengeId)
    }
}
