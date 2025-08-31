//
//  AppleLoginUseCase.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared

protocol AppleLoginUseCaseProtocol {
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AuthState, Never>
}

final class AppleLoginUseCase: AppleLoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AuthState, Never> {
        Just(.authenticating)
            .append(
                repository.loginWithApple(request: request)
                    .map { _ in AuthState.authenticated } // 로그인 성공 시 인증됨
                    .catch { error -> AnyPublisher<AuthState, Never> in
                        Just(.error(error)).eraseToAnyPublisher()
                    }
            )
            .eraseToAnyPublisher()
    }
}
