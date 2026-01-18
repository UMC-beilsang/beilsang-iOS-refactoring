//
//  RevokeUseCase.swift
//  AuthDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import Combine
import ModelsShared
import StorageCore

public protocol RevokeUseCaseProtocol {
    func revoke() -> AnyPublisher<Void, AuthError>
}

public final class RevokeUseCase: RevokeUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol

    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    public func revoke() -> AnyPublisher<Void, AuthError> {
        // 저장된 토큰에서 provider 정보 확인
        return tokenStorage.getToken()
            .mapError { AuthError.fromKeychainError($0) }
            .flatMap { [weak self] token -> AnyPublisher<Void, AuthError> in
                guard let self = self else {
                    return Fail(error: AuthError.unknownError("RevokeUseCase deallocated"))
                        .eraseToAnyPublisher()
                }
                
                guard let token = token else {
                    #if DEBUG
                    print("⚠️ No token found, cannot determine provider")
                    #endif
                    return Fail(error: AuthError.unknownError("토큰을 찾을 수 없습니다"))
                        .eraseToAnyPublisher()
                }
                
                // 저장된 provider에 따라 적절한 탈퇴 API 호출
                let provider = token.provider ?? .kakao // 기본값은 kakao (하위 호환성)
                
                #if DEBUG
                print("🚪 Revoking account with provider: \(provider.rawValue)")
                #endif
                
                switch provider {
                case .kakao:
                    return self.repository.revokeKakao()
                case .apple:
                    return self.repository.revokeApple()
                }
            }
            .flatMap { [weak self] _ -> AnyPublisher<Void, AuthError> in
                guard let self = self else {
                    return Fail(error: AuthError.unknownError("RevokeUseCase deallocated"))
                        .eraseToAnyPublisher()
                }
                // 탈퇴 성공 시 토큰 삭제
                return self.tokenStorage.deleteToken()
                    .mapError { AuthError.fromKeychainError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

