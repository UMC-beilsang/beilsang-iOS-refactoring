//
//  FetchUserProfileUseCase.swift
//  UserDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import ModelsShared

public protocol FetchUserProfileUseCaseProtocol {
    func execute() async throws -> UserProfileData
}

public final class FetchUserProfileUseCase: FetchUserProfileUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> UserProfileData {
        try await repository.fetchUserProfile()
    }
}


