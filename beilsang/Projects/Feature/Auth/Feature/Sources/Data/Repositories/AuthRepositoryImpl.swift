//
//  AuthRepositoryImpl.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser
import ModelsShared

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let networkService: AuthNetworkServiceProtocol
    private let tokenStorage: AuthTokenStorageProtocol
    
    init(networkService: AuthNetworkServiceProtocol, tokenStorage: AuthTokenStorageProtocol) {
        self.networkService = networkService
        self.tokenStorage = tokenStorage
    }
    
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<AuthToken, AuthError> {
        networkService.loginWithKakao(request: request)
            .map { response in
                // KakaoLoginResponse → AuthToken 변환
                AuthToken(
                    accessToken: response.data.accessToken,
                    refreshToken: response.data.refreshToken,
                    tokenType: "Bearer"
                )
            }
            .flatMap { [weak self] token -> AnyPublisher<AuthToken, AuthError> in
                guard let self = self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.saveToken(token).map { token }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AuthToken, AuthError> {
        networkService.loginWithApple(request: request)
            .map { response in
                // AppleLoginResponse → AuthToken 변환
                AuthToken(
                    accessToken: response.data.accessToken,
                    refreshToken: response.data.refreshToken,
                    tokenType: "Bearer"
                )
            }
            .flatMap { [weak self] token -> AnyPublisher<AuthToken, AuthError> in
                guard let self = self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.saveToken(token).map { token }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func signUp(request: SignUpRequest) -> AnyPublisher<AuthToken, AuthError> {
        networkService.signUp(request: request)
            .map { _ in
                // 회원가입 성공 시 refreshToken API로 토큰 받아야 할 수도 있음 (서버 스펙에 맞게 조정)
                AuthToken(
                    accessToken: "", // 서버 응답 구조 확인 필요
                    refreshToken: "",
                    tokenType: "Bearer"
                )
            }
            .eraseToAnyPublisher()
    }
    
    func refreshToken() -> AnyPublisher<AuthToken, AuthError> {
        tokenStorage.getToken()
            .setFailureType(to: AuthError.self)
            .flatMap { [weak self] token -> AnyPublisher<AuthToken, AuthError> in
                guard let self = self,
                      let token = token else {
                    return Fail(error: .tokenExpired).eraseToAnyPublisher()
                }
                return self.networkService.refreshToken(token.refreshToken)
            }
            .flatMap { [weak self] newToken -> AnyPublisher<AuthToken, AuthError> in
                guard let self = self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.saveToken(newToken).map { newToken }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func revokeKakao() -> AnyPublisher<Void, AuthError> {
        networkService.revokeKakao()
            .flatMap { [weak self] _ -> AnyPublisher<Void, AuthError> in
                guard let self = self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.deleteToken()
            }
            .eraseToAnyPublisher()
    }
    
    func revokeApple() -> AnyPublisher<Void, AuthError> {
        networkService.revokeApple()
            .flatMap { [weak self] _ -> AnyPublisher<Void, AuthError> in
                guard let self = self else {
                    return Fail(error: .unknownError("Repository deallocated")).eraseToAnyPublisher()
                }
                return self.tokenStorage.deleteToken()
            }
            .eraseToAnyPublisher()
    }
}
