//
//  AppleLoginUseCase.swift
//  AuthDomain
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared

public protocol AppleLoginUseCaseProtocol {
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AuthState, Never>
}

public final class AppleLoginUseCase: AppleLoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AuthState, Never> {
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
