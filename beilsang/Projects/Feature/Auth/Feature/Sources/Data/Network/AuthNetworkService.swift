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
import AuthDomain

final class AuthNetworkService: AuthNetworkServiceProtocol {
    private let session: Session
    private let baseURL: String
    
    init(session: Session = .default, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<KeychainToken, AuthError> {
        do {
            let urlRequest = try AuthRouter.kakaoLogin(request).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: KeychainToken.self)
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<KeychainToken, AuthError> {
        do {
            let urlRequest = try AuthRouter.appleLogin(request).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: KeychainToken.self)
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    func signUp(request: SignUpRequest) -> AnyPublisher<KeychainToken, AuthError> {
        do {
            let urlRequest = try AuthRouter.signup(request).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: KeychainToken.self)
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    func refreshToken(_ token: String) -> AnyPublisher<KeychainToken, AuthError> {
        do {
            let urlRequest = try AuthRouter.refresh(token).asURLRequest(baseURL: baseURL)
            return session.request(urlRequest)
                .validate()
                .publishDecodable(type: KeychainToken.self)
                .value()
                .mapError { self.mapNetworkError($0) }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .networkError).eraseToAnyPublisher()
        }
    }
    
    func revokeKakao() -> AnyPublisher<Void, AuthError> {
        do {
            let urlRequest = try AuthRouter.revokeKakao.asURLRequest(baseURL: baseURL)
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
