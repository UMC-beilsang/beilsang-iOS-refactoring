//
//  LogoutUseCase.swift
//  AuthDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared
import StorageCore

public protocol LogoutUseCaseProtocol {
    func logout() async throws
}

public final class LogoutUseCase: LogoutUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol

    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    public func logout() async throws {
        do {
            let token = try await tokenStorage.getToken()
            
            guard let token = token, let provider = token.provider else {
                #if DEBUG
                print("⚠️ No provider found, skipping logout API call")
                #endif
                try await tokenStorage.deleteToken()
                return
            }
            
            #if DEBUG
            print("🚪 Logging out with provider: \(provider.rawValue)")
            #endif
            
            do {
                switch provider {
                case .kakao:
                    try await repository.logoutKakao()
                case .apple:
                    #if DEBUG
                    print("🍎 Apple logout: 클라이언트에서만 처리 (토큰 삭제)")
                    #endif
                }
            } catch {
                #if DEBUG
                print("❌ 로그아웃 API 실패: \(error), but continuing with token deletion")
                #endif
            }
            
            try await tokenStorage.deleteToken()
            
        } catch let keychainError as KeychainError {
            throw AuthError.fromKeychainError(keychainError)
        }
    }
}
