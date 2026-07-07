//
//  AuthRepositoryProtocol.swift
//  AuthDomain
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import ModelsShared

// MARK: - Repository
public protocol AuthRepositoryProtocol {
    func checkNickname(_ nickname: String) async throws -> Bool
    func loginWithKakao(request: KakaoLoginRequest) async throws -> (KeychainToken, Bool)
    func loginWithApple(request: AppleLoginRequest) async throws -> (KeychainToken, Bool)
    func signUpSimplified(agreed: Bool) async throws
    func logoutKakao() async throws
    func revokeKakao() async throws
    func revokeApple() async throws
}
