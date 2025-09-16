//
//  AuthRepositoryImpl.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared
import AuthDomain
import NetworkCore
import StorageCore

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let networkService: AuthNetworkServiceProtocol
    private let tokenStorage: KeychainTokenStorageProtocol
    
    init(networkService: AuthNetworkServiceProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }
    
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<KeychainToken, AuthError> {
        networkService.loginWithKakao(request: request)
            .flatMap { [weak self] token -> AnyPublisher<KeychainToken, AuthError> in
                guard let self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.saveToken(token)
                    .mapError { _ in AuthError.networkError } // 단순 매핑
                    .map { token }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<KeychainToken, AuthError> {
        networkService.loginWithApple(request: request)
            .flatMap { [weak self] token -> AnyPublisher<KeychainToken, AuthError> in
                guard let self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.saveToken(token)
                    .mapError { _ in AuthError.networkError }
                    .map { token }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func signUp(request: SignUpRequest) -> AnyPublisher<KeychainToken, AuthError> {
        networkService.signUp(request: request)
            .flatMap { [weak self] token -> AnyPublisher<KeychainToken, AuthError> in
                guard let self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.saveToken(token)
                    .mapError { _ in AuthError.networkError }
                    .map { token }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func refreshToken() -> AnyPublisher<KeychainToken, AuthError> {
        tokenStorage.getToken()
            .mapError { _ in AuthError.networkError }
            .flatMap { [weak self] token -> AnyPublisher<KeychainToken, AuthError> in
                guard let self, let token else {
                    return Fail(error: .tokenExpired).eraseToAnyPublisher()
                }
                return self.networkService.refreshToken(token.refreshToken)
            }
            .flatMap { [weak self] newToken -> AnyPublisher<KeychainToken, AuthError> in
                guard let self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.saveToken(newToken)
                    .mapError { _ in AuthError.networkError }
                    .map { newToken }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func revokeKakao() -> AnyPublisher<Void, AuthError> {
        networkService.revokeKakao()
            .flatMap { [weak self] _ -> AnyPublisher<Void, AuthError> in
                guard let self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.deleteToken()
                    .mapError { _ in AuthError.networkError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func revokeApple() -> AnyPublisher<Void, AuthError> {
        networkService.revokeApple()
            .flatMap { [weak self] _ -> AnyPublisher<Void, AuthError> in
                guard let self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.deleteToken()
                    .mapError { _ in AuthError.networkError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
