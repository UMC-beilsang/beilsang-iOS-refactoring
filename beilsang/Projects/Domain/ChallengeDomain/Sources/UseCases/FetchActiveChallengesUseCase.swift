//
//  FetchActiveChallengesUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol FetchActiveChallengesUseCaseProtocol {
    func execute() async throws -> [Challenge]
}

public final class FetchActiveChallengesUseCase: FetchActiveChallengesUseCaseProtocol {
    private let repository: ChallengeRepositoryProtocol
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> [Challenge] {
        try await repository.fetchActiveChallenges()
    }
}


