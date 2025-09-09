//
//  AuthRepositoryProtocol.swift
//  AuthDomain
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared

// MARK: - Repository
public protocol AuthRepositoryProtocol {
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<KeychainToken, AuthError>
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<KeychainToken, AuthError>
    func signUp(request: SignUpRequest) -> AnyPublisher<KeychainToken, AuthError>
    func refreshToken() -> AnyPublisher<KeychainToken, AuthError>
    func revokeKakao() -> AnyPublisher<Void, AuthError>
    func revokeApple() -> AnyPublisher<Void, AuthError>
}

// MARK: - Network Service
public protocol AuthNetworkServiceProtocol {
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<KeychainToken, AuthError>
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<KeychainToken, AuthError>
    func signUp(request: SignUpRequest) -> AnyPublisher<KeychainToken, AuthError>
    func refreshToken(_ token: String) -> AnyPublisher<KeychainToken, AuthError>
    func revokeKakao() -> AnyPublisher<Void, AuthError>
    func revokeApple() -> AnyPublisher<Void, AuthError>
}
