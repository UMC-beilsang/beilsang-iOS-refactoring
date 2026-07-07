//
//  FetchActiveChallengesUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol FetchActiveChallengesUseCaseProtocol {
    func execute() async throws -> [ChallengeItem]
}

public final class FetchActiveChallengesUseCase: FetchActiveChallengesUseCaseProtocol {
    private let repository: ChallengeQueryRepositoryProtocol
    
    public init(repository: ChallengeQueryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> [ChallengeItem] {
        // 나의 진행중인 챌린지 (ONGOING 상태)
        let request = MyChallengeListRequest(
            category: nil,
            participationStatus: "ONGOING",
            page: 0,
            size: 20
        )
        
        let response = try await repository.fetchMyChallenges(request: request)
        return response.content 
    }
}
