//
//  SignUpUseCase.swift
//  AuthDomain
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import ModelsShared

public protocol SignUpUseCaseProtocol {
    func checkNickname(_ nickname: String) async throws -> Bool
    func signUpSimplified(agreed: Bool) async -> AuthState
}

public final class SignUpUseCase: SignUpUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func checkNickname(_ nickname: String) async throws -> Bool {
        return try await repository.checkNickname(nickname)
    }
    
    public func signUpSimplified(agreed: Bool) async -> AuthState {
        do {
            try await repository.signUpSimplified(agreed: agreed)
            return .authenticated
        } catch let authError as AuthError {
            return .error(authError)
        } catch {
            return .error(.unknownError(error.localizedDescription))
        }
    }
}
