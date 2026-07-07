//
//  ToggleChallengeLikeUseCase.swift
//  ChallengeDomain
//
//  Created by Cursor on 2/28/26.
//

import Foundation

// MARK: - Protocol
public protocol ToggleChallengeLikeUseCaseProtocol: Sendable {
    func execute(challengeId: Int, currentlyLiked: Bool) async throws
}

// MARK: - Implementation
public final class ToggleChallengeLikeUseCase: ToggleChallengeLikeUseCaseProtocol {
    private let repository: ChallengeCommandRepositoryProtocol
    
    public init(repository: ChallengeCommandRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(challengeId: Int, currentlyLiked: Bool) async throws {
        if currentlyLiked {
            try await repository.unlikeChallenge(challengeId: challengeId)
        } else {
            try await repository.likeChallenge(challengeId: challengeId)
        }
    }
}
