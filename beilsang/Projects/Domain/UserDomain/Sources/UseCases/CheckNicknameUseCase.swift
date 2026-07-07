//
//  CheckNicknameUseCase.swift
//  UserDomain
//
//  Created by Seyoung Park on 12/02/25.
//

import Foundation

public protocol CheckNicknameUseCaseProtocol {
    func execute(_ nickname: String) async throws -> Bool
}

public final class CheckNicknameUseCase: CheckNicknameUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(_ nickname: String) async throws -> Bool {
        try await repository.checkNickname(nickname)
    }
}
