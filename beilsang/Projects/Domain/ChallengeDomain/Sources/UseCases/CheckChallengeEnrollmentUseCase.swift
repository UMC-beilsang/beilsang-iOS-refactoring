//
//  CheckChallengeEnrollmentUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol CheckChallengeEnrollmentUseCaseProtocol {
    func execute(challengeId: Int) async throws -> ChallengeEnrollmentData
}

public final class CheckChallengeEnrollmentUseCase: CheckChallengeEnrollmentUseCaseProtocol {
    private let repository: ChallengeRepositoryProtocol
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(challengeId: Int) async throws -> ChallengeEnrollmentData {
        try await repository.checkChallengeEnrollment(challengeId: challengeId)
    }
}


