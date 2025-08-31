//
//  AuthRepositoryProtocol.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared

// MARK: - Repository
protocol AuthRepositoryProtocol {
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<AuthToken, AuthError>
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AuthToken, AuthError>
    func signUp(request: SignUpRequest) -> AnyPublisher<AuthToken, AuthError>
    func refreshToken() -> AnyPublisher<AuthToken, AuthError>
    func revokeKakao() -> AnyPublisher<Void, AuthError>
    func revokeApple() -> AnyPublisher<Void, AuthError>
}

// MARK: - Network Service
protocol AuthNetworkServiceProtocol {
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<KakaoLoginResponse, AuthError>
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AppleLoginResponse, AuthError>
    func signUp(request: SignUpRequest) -> AnyPublisher<SignUpResponse, AuthError>
    func refreshToken(_ token: String) -> AnyPublisher<AuthToken, AuthError>
    func revokeKakao() -> AnyPublisher<Void, AuthError>
    func revokeApple() -> AnyPublisher<Void, AuthError>
}

// MARK: - Storage
protocol AuthTokenStorageProtocol {
    func saveToken(_ token: AuthToken) -> AnyPublisher<Void, AuthError>
    func getToken() -> AnyPublisher<AuthToken?, Never>
    func deleteToken() -> AnyPublisher<Void, AuthError>
}
