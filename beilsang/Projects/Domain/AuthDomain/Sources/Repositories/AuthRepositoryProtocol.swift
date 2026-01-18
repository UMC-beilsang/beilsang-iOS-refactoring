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
    func checkNickname(_ nickname: String) -> AnyPublisher<Bool, AuthError>
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<(KeychainToken, Bool), AuthError>
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<(KeychainToken, Bool), AuthError>
    func signUp(request: SignUpRequest) -> AnyPublisher<KeychainToken, AuthError>
    func logoutKakao() -> AnyPublisher<Void, AuthError>
    func revokeKakao() -> AnyPublisher<Void, AuthError>
    func revokeApple() -> AnyPublisher<Void, AuthError>
}
