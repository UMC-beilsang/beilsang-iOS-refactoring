//
//  FetchChallengeListUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import ModelsShared

public protocol FetchChallengeListUseCaseProtocol {
    func execute(request: ChallengeListRequest) async throws -> [Challenge]
}

public final class FetchChallengeListUseCase: FetchChallengeListUseCaseProtocol {
    private let repository: ChallengeRepositoryProtocol
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(request: ChallengeListRequest) async throws -> [Challenge] {
        try await repository.fetchChallengeList(request: request)
    }
}





