//
//  SignUpUseCase.swift
//  AuthDomain
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared
import StorageCore

public protocol SignUpUseCaseProtocol {
    func checkNickname(_ nickname: String) -> AnyPublisher<Bool, AuthError>
    func signUp(data: SignUpData) -> AnyPublisher<AuthState, Never>
    func signUpSimplified(marketingAgreed: Bool) -> AnyPublisher<AuthState, Never>
}

public final class SignUpUseCase: SignUpUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol
    
    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Nickname Check
    public func checkNickname(_ nickname: String) -> AnyPublisher<Bool, AuthError> {
        return repository.checkNickname(nickname)
    }
    
    // MARK: - Sign Up
    public func signUp(data: SignUpData) -> AnyPublisher<AuthState, Never> {
        let request = data.toRequest()
        
        // 회원가입 전에 기존 토큰의 provider 정보 가져오기 (회원가입 전에 로그인했으므로)
        return tokenStorage.getToken()
            .mapError { _ in AuthError.unknownError("Failed to get existing token") }
            .flatMap { [repository, tokenStorage] existingToken -> AnyPublisher<AuthState, AuthError> in
                repository.signUp(request: request)
                    .flatMap { newToken -> AnyPublisher<AuthState, AuthError> in
                        // 기존 토큰의 provider 정보를 새 토큰에 유지
                        let tokenWithProvider = KeychainToken(
                            accessToken: newToken.accessToken,
                            refreshToken: newToken.refreshToken,
                            tokenType: newToken.tokenType,
                            expiresIn: newToken.expiresIn,
                            createdAt: newToken.createdAt,
                            provider: existingToken?.provider // 기존 provider 유지
                        )
                        return tokenStorage.saveToken(tokenWithProvider)
                            .map { AuthState.authenticated }
                            .mapError { AuthError.fromKeychainError($0) }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .catch { error in Just(AuthState.error(error)) }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sign Up Simplified (약관 동의만)
    public func signUpSimplified(marketingAgreed: Bool) -> AnyPublisher<AuthState, Never> {
        // 기존 토큰의 provider 정보 가져오기
        return tokenStorage.getToken()
            .mapError { _ in AuthError.unknownError("Failed to get existing token") }
            .flatMap { [repository, tokenStorage] existingToken -> AnyPublisher<AuthState, AuthError> in
                guard let token = existingToken else {
                    return Just(AuthState.error(.unknownError("No token found")))
                        .setFailureType(to: AuthError.self)
                        .eraseToAnyPublisher()
                }
                
                let request = SignUpSimplifiedRequest(
                    accessToken: token.accessToken,
                    marketingAgreed: marketingAgreed
                )
                
                return repository.signUpSimplified(request: request)
                    .flatMap { newToken -> AnyPublisher<AuthState, AuthError> in
                        // 기존 토큰의 provider 정보를 새 토큰에 유지
                        let tokenWithProvider = KeychainToken(
                            accessToken: newToken.accessToken,
                            refreshToken: newToken.refreshToken,
                            tokenType: newToken.tokenType,
                            expiresIn: newToken.expiresIn,
                            createdAt: newToken.createdAt,
                            provider: existingToken?.provider // 기존 provider 유지
                        )
                        return tokenStorage.saveToken(tokenWithProvider)
                            .map { AuthState.authenticated }
                            .mapError { AuthError.fromKeychainError($0) }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .catch { error in Just(AuthState.error(error)) }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
}
