//
//  KakaoLoginUseCase.swift
//  AuthDomain
//
//  Created by Seyoung Park on 10/07/25.
//

import Foundation
import ModelsShared
import StorageCore

public protocol KakaoLoginUseCaseProtocol {
    func login(request: KakaoLoginRequest) async -> AuthState
}

public final class KakaoLoginUseCase: KakaoLoginUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    private let tokenStorage: KeychainTokenStorageProtocol

    public init(repository: AuthRepositoryProtocol, tokenStorage: KeychainTokenStorageProtocol) {
        self.repository = repository
        self.tokenStorage = tokenStorage
    }

    public func login(request: KakaoLoginRequest) async -> AuthState {
        do {
            #if DEBUG
            print("🔄 KakaoLoginUseCase: Calling repository.loginWithKakao...")
            #endif
            
            let (token, isTermsAgreed) = try await repository.loginWithKakao(request: request)
            
            #if DEBUG
            print("✅ KakaoLoginUseCase: Repository returned - isTermsAgreed: \(isTermsAgreed)")
            #endif
            
            let tokenWithProvider = KeychainToken(
                accessToken: token.accessToken,
                refreshToken: token.refreshToken,
                tokenType: token.tokenType,
                expiresIn: token.expiresIn,
                createdAt: token.createdAt,
                provider: .kakao
            )
            
            do {
                try await tokenStorage.saveToken(tokenWithProvider)
                
                #if DEBUG
                print("✅ KakaoLoginUseCase: Token saved - returning \(isTermsAgreed ? "authenticated" : "needsSignUp")")
                #endif
                
                // isTermsAgreed가 true면 기존 회원 (약관 동의 완료) → authenticated
                // isTermsAgreed가 false면 신규 회원 (약관 동의 필요) → needsSignUp
                return isTermsAgreed ? .authenticated : .needsSignUp
            } catch let keychainError as KeychainError {
                return .error(AuthError.fromKeychainError(keychainError))
            } catch {
                return .error(.unknownError(error.localizedDescription))
            }
        } catch let authError as AuthError {
            return .error(authError)
        } catch {
            return .error(.unknownError(error.localizedDescription))
        }
    }
}
