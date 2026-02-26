//
//  JoinChallengeUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation

public protocol JoinChallengeUseCaseProtocol {
    func execute(challengeId: Int) async throws
}

public final class JoinChallengeUseCase: JoinChallengeUseCaseProtocol {
    private let repository: ChallengeRepositoryProtocol
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(challengeId: Int) async throws {
        try await repository.participateInChallenge(challengeId: challengeId)
    }
}
