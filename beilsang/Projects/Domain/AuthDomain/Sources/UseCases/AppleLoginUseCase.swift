//
//  AppleLoginUseCase.swift
//  AuthDomain
//
//  Created by Seyoung Park on 10/07/25.
//

import Foundation
import ModelsShared
import StorageCore

public protocol AppleLoginUseCaseProtocol {
    func login(request: AppleLoginRequest) async -> AuthState
}

public final class AppleLoginUseCase: AppleLoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol

    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    public func login(request: AppleLoginRequest) async -> AuthState {
        do {
            let (token, isTermsAgreed) = try await repository.loginWithApple(request: request)
            
            let tokenWithProvider = KeychainToken(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken,
                tokenType: token.tokenType,
                expiresIn: token.expiresIn,
                createdAt: token.createdAt,
                provider: .apple
            )
            
            do {
                try await tokenStorage.saveToken(tokenWithProvider)
                return isTermsAgreed ? .authenticated : .needsSignUp
            } catch let keychainError as KeychainError {
                return .error(AuthError.fromKeychainError(keychainError))
            } catch {
                return .error(.unknownError(error.localizedDescription))
            }
        } catch let authError as AuthError {
            return .error(authError)
        } catch {
            return .error(.unknownError(error.localizedDescription))
        }
    }
}
