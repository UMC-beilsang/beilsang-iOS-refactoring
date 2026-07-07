//
//  RevokeUseCase.swift
//  AuthDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared
import StorageCore

public protocol RevokeUseCaseProtocol {
    func revoke() async throws
}

public final class RevokeUseCase: RevokeUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol

    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    public func revoke() async throws {
        do {
            let token = try await tokenStorage.getToken()
            
            guard let token = token else {
                #if DEBUG
                print("⚠️ No token found, cannot determine provider")
                #endif
                throw AuthError.unknownError("토큰을 찾을 수 없습니다")
            }
            
            let provider = token.provider ?? .kakao
            
            #if DEBUG
            print("🚪 Revoking account with provider: \(provider.rawValue)")
            #endif
            
            switch provider {
            case .kakao:
                try await repository.revokeKakao()
            case .apple:
                try await repository.revokeApple()
            }
            
            try await tokenStorage.deleteToken()
            
        } catch let keychainError as KeychainError {
            throw AuthError.fromKeychainError(keychainError)
        }
    }
}
