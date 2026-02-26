//
//  UpdateProfileImageUseCase.swift
//  UserDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation

public protocol UpdateProfileImageUseCaseProtocol {
    /// Returns updated profile image URL if server provides it, otherwise empty string.
    func execute(imageBase64: String) async throws -> String
}

public final class UpdateProfileImageUseCase: UpdateProfileImageUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(imageBase64: String) async throws -> String {
        try await repository.updateProfileImage(imageBase64: imageBase64)
    }
}


