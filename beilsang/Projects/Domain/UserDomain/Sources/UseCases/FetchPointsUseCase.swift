//
//  FetchPointsUseCase.swift
//  UserDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol FetchPointsUseCaseProtocol {
    func execute() async throws -> PointData
}

public final class FetchPointsUseCase: FetchPointsUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> PointData {
        try await repository.fetchPoints()
    }
}


