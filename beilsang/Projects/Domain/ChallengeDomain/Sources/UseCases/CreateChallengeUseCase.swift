//
//  CreateChallengeUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol CreateChallengeUseCaseProtocol {
    func execute(
        request: ChallengeCreateRequest,
        infoImages: [Data],
        certImages: [Data]
    ) async throws -> ChallengeCreateResponse
}

public final class CreateChallengeUseCase: CreateChallengeUseCaseProtocol {
    private let repository: ChallengeRepositoryProtocol
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(
        request: ChallengeCreateRequest,
        infoImages: [Data],
        certImages: [Data]
    ) async throws -> ChallengeCreateResponse {
        try await repository.createChallenge(
            request: request,
            infoImages: infoImages,
            certImages: certImages
        )
    }
}
