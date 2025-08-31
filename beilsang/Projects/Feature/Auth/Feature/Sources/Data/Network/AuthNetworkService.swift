//
//  AuthNetworkService.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import Alamofire
import NetworkCore
import ModelsShared

final class AuthNetworkService: AuthNetworkServiceProtocol {
    private let session: Session
    private let baseURL: String
    
    init(session: Session = .default, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    // ✅ 카카오 로그인
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<KakaoLoginResponse, AuthError> {
        do {
            let urlRequest = try AuthRouter.kakaoLogin(request).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: KakaoLoginResponse.self)
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    // ✅ 애플 로그인
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<AppleLoginResponse, AuthError> {
        do {
            let urlRequest = try AuthRouter.appleLogin(request).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: AppleLoginResponse.self)
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    // ✅ 회원가입
    func signUp(request: SignUpRequest) -> AnyPublisher<SignUpResponse, AuthError> {
        do {
            let urlRequest = try AuthRouter.signup(request).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: SignUpResponse.self)
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    // ✅ 토큰 갱신
    func refreshToken(_ token: String) -> AnyPublisher<AuthToken, AuthError> {
        do {
            let urlRequest = try AuthRouter.refresh(token).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: AuthToken.self) // 서버가 바로 토큰 내려주는 구조라고 가정
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    // ✅ 카카오 계정 연결 해제 (탈퇴)
    func revokeKakao() -> AnyPublisher<Void, AuthError> {
        do {
            let urlRequest = try AuthRouter.revokeKakao.asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishData() // Void 타입일 경우
                .map { _ in () }
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    // ✅ 애플 계정 연결 해제 (탈퇴)
    func revokeApple() -> AnyPublisher<Void, AuthError> {
        do {
            let urlRequest = try AuthRouter.revokeApple.asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishData()
                .map { _ in () }
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    // MARK: - 공통 에러 매핑
    private func mapNetworkError(_ error: Error) -> AuthError {
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(reason: .unacceptableStatusCode(code: 401)):
                return .invalidCredentials
            case .responseValidationFailed(reason: .unacceptableStatusCode(code: 403)):
                return .tokenExpired
            default:
                return .networkError
            }
        }
        return .networkError
    }
}
