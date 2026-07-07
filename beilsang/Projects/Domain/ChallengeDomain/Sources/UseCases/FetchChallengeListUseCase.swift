//
//  FetchChallengeListUseCase.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import ModelsShared

public protocol FetchChallengeListUseCaseProtocol {
    // 새 API 엔드포인트들
    func executeOpen(request: OpenChallengeListRequest) async throws -> ChallengePageData
    func executeClosed(request: ClosedChallengeListRequest) async throws -> ChallengePageData
    func executeLiked(request: LikedChallengeListRequest) async throws -> ChallengePageData
    func executeMy(request: MyChallengeListRequest) async throws -> ChallengePageData
    func searchOpen(request: SearchOpenChallengeRequest) async throws -> ChallengePageData
    func searchClosed(request: SearchClosedChallengeRequest) async throws -> ChallengePageData
}

public final class FetchChallengeListUseCase: FetchChallengeListUseCaseProtocol {
    private let repository: ChallengeQueryRepositoryProtocol
    
    public init(repository: ChallengeQueryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func executeOpen(request: OpenChallengeListRequest) async throws -> ChallengePageData {
        try await repository.fetchOpenChallenges(request: request)
    }
    
    public func executeClosed(request: ClosedChallengeListRequest) async throws -> ChallengePageData {
        try await repository.fetchClosedChallenges(request: request)
    }
    
    public func executeLiked(request: LikedChallengeListRequest) async throws -> ChallengePageData {
        try await repository.fetchLikedChallenges(request: request)
    }
    
    public func executeMy(request: MyChallengeListRequest) async throws -> ChallengePageData {
        try await repository.fetchMyChallenges(request: request)
    }
    
    public func searchOpen(request: SearchOpenChallengeRequest) async throws -> ChallengePageData {
        try await repository.searchOpenChallenges(request: request)
    }
    
    public func searchClosed(request: SearchClosedChallengeRequest) async throws -> ChallengePageData {
        try await repository.searchClosedChallenges(request: request)
    }
}





