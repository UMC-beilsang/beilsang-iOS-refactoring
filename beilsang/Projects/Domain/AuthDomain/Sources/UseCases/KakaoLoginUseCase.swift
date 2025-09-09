//
//  KakaoLoginUseCase.swift
//  AuthDomain
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared

public protocol KakaoLoginUseCaseProtocol {
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<AuthState, Never>
}

public final class KakaoLoginUseCase: KakaoLoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<AuthState, Never> {
        Just(.authenticating)
            .append(
                repository.loginWithKakao(request: request)
                    .map { _ in AuthState.authenticated }
                    .catch { error -> AnyPublisher<AuthState, Never> in
                        Just(.error(error)).eraseToAnyPublisher()
                    }
            )
            .eraseToAnyPublisher()
    }
}
