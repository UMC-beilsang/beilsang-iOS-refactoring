//
//  FetchMyFeedsUseCase.swift
//  UserDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol FetchMyFeedsUseCaseProtocol {
    func execute(page: Int, size: Int) async throws -> FeedListResponse
}

public final class FetchMyFeedsUseCase: FetchMyFeedsUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(page: Int, size: Int) async throws -> FeedListResponse {
        try await repository.fetchMyFeeds(page: page, size: size)
    }
}


