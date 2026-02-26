//
//  LogoutUseCase.swift
//  AuthDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import Combine
import ModelsShared
import StorageCore

public protocol LogoutUseCaseProtocol {
    func logout() -> AnyPublisher<Void, AuthError>
}

public final class LogoutUseCase: LogoutUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol

    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    public func logout() -> AnyPublisher<Void, AuthError> {
        // 저장된 토큰에서 provider 정보 확인
        return tokenStorage.getToken()
            .mapError { AuthError.fromKeychainError($0) }
            .flatMap { [weak self] token -> AnyPublisher<Void, AuthError> in
                guard let self = self else {
                    return Fail(error: AuthError.unknownError("LogoutUseCase deallocated"))
                        .eraseToAnyPublisher()
                }
                
                // provider가 있으면 해당 로그아웃 API 호출, 없으면 바로 성공 처리
                guard let token = token, let provider = token.provider else {
                    #if DEBUG
                    print("⚠️ No provider found, skipping logout API call")
                    #endif
                    // provider가 없으면 바로 성공 처리 (하위 호환성)
                    return Just(())
                        .setFailureType(to: AuthError.self)
                        .eraseToAnyPublisher()
                }
                
                #if DEBUG
                print("🚪 Logging out with provider: \(provider.rawValue)")
                #endif
                
                // 저장된 provider에 따라 적절한 로그아웃 API 호출
                switch provider {
                case .kakao:
                    // 카카오는 서버 로그아웃 API 호출
                    return self.repository.logoutKakao()
                case .apple:
                    // 애플은 클라이언트에서만 처리 (서버 API 없음)
                    #if DEBUG
                    print("🍎 Apple logout: 클라이언트에서만 처리 (토큰 삭제)")
                    #endif
                    return Just(())
                        .setFailureType(to: AuthError.self)
                        .eraseToAnyPublisher()
                }
            }
            .catch { error -> AnyPublisher<Void, AuthError> in
                // 로그아웃 API 실패해도 토큰은 삭제하고 진행 (클라이언트 토큰 삭제는 필수)
                #if DEBUG
                print("❌ 로그아웃 API 실패: \(error), but continuing with token deletion")
                #endif
                return Just(())
                    .setFailureType(to: AuthError.self)
                    .eraseToAnyPublisher()
            }
            .flatMap { [weak self] _ -> AnyPublisher<Void, AuthError> in
                guard let self = self else {
                    return Fail(error: AuthError.unknownError("LogoutUseCase deallocated"))
                        .eraseToAnyPublisher()
                }
                // API 성공/실패와 관계없이 토큰 삭제 진행
                return self.tokenStorage.deleteToken()
                    .mapError { AuthError.fromKeychainError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

