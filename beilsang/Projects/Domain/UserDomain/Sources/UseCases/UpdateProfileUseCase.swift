//
//  UpdateProfileUseCase.swift
//  UserDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation
import ModelsShared

public protocol UpdateProfileUseCaseProtocol {
    func execute(request: ProfileUpdateRequest) async throws -> ProfileUpdateResponse
}

public final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(request: ProfileUpdateRequest) async throws -> ProfileUpdateResponse {
        try await repository.updateProfile(request: request)
    }
}


