//
//  KakaoLoginUseCase.swift
//  AuthDomain
//
//  Created by Seyoung Park on 10/07/25.
//

import Foundation
import Combine
import ModelsShared
import StorageCore

public protocol KakaoLoginUseCaseProtocol {
    func login(request: KakaoLoginRequest) -> AnyPublisher<AuthState, Never>
}

public final class KakaoLoginUseCase: KakaoLoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol

    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    public func login(request: KakaoLoginRequest) -> AnyPublisher<AuthState, Never> {
        return repository.loginWithKakao(request: request)
            .flatMap { [tokenStorage] token, isExistMember -> AnyPublisher<AuthState, AuthError> in
                // 카카오 로그인 provider 정보 추가
                let tokenWithProvider = KeychainToken(
                    accessToken: token.accessToken,
                    refreshToken: token.refreshToken,
                    tokenType: token.tokenType,
                    expiresIn: token.expiresIn,
                    createdAt: token.createdAt,
                    provider: .kakao
                )
                return tokenStorage.saveToken(tokenWithProvider)
                    .map { _ in
                        // isExistMember가 false면 신규 회원 (회원가입 필요)
                        // isExistMember가 true면 기존 회원 (인증 완료)
                        isExistMember ? AuthState.authenticated : AuthState.needsSignUp
                    }
                    .mapError { AuthError.fromKeychainError($0) }
                    .eraseToAnyPublisher()
            }
            .catch { error in Just(AuthState.error(error)) }
            .prepend(.loading)
            .eraseToAnyPublisher()
    }
}
