//
//  AuthRepository.swift
//  AuthData
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared
import NetworkCore
import UtilityShared
import Alamofire

public final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    public init(baseURL: String) {
        self.apiClient = APIClient(baseURL: baseURL)
    }
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Nickname Check
    public func checkNickname(_ nickname: String) -> AnyPublisher<Bool, AuthError> {
        guard nickname.isEmpty == false else {
            return Fail(error: .serverError("닉네임이 올바르지 않습니다."))
                .eraseToAnyPublisher()
        }
        
        if MockConfig.useMockData {
            #if DEBUG
            print("🔍 Using mock nickname check: \(nickname)")
            #endif
            let isAvailable = !nickname.lowercased().contains("중복") && !nickname.lowercased().contains("duplicate")
            return Just(isAvailable)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        
        #if DEBUG
        print("🔍 Checking nickname: \(nickname)")
        #endif
        
        guard let encoded = nickname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return Fail(error: .serverError("닉네임 인코딩 실패"))
                .eraseToAnyPublisher()
        }
        
        let path = "api/oauth/nickname?nickname=\(encoded)"
        typealias NicknameResponse = APIResponse<String>
        let publisher: AnyPublisher<NicknameResponse, APIClientError> = apiClient.request(
            path: path,
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return publisher
            .mapError(AuthRepository.mapAPIError(_:))
            .tryMap { response -> Bool in
                #if DEBUG
                print("🔍 Nickname check response - statusCode: \(response.statusCode), code: \(response.code), message: \(response.message)")
                #endif
                
                // 200: 유효한 닉네임, 400: 유효하지 않은 닉네임
                switch response.statusCode {
                case 200:
                    #if DEBUG
                    print("✅ Nickname is available")
                    #endif
                    return true
                case 400:
                    #if DEBUG
                    print("❌ Nickname is invalid or duplicate")
                    #endif
                    return false
                default:
                    throw AuthError.serverError(response.message)
                }
            }
            .mapError { $0 as? AuthError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Kakao Login
    public func loginWithKakao(request: KakaoLoginRequest) -> AnyPublisher<(KeychainToken, Bool), AuthError> {
        if MockConfig.useMockData {
            #if DEBUG
            print("🟡 Using mock Kakao login")
            #endif
            let token = KeychainToken(
                accessToken: "mock_kakao_access_token_\(UUID().uuidString)",
                refreshToken: "mock_kakao_refresh_token_\(UUID().uuidString)",
                expiresIn: 3600
            )
            // Mock에서는 항상 신규 회원으로 가정
            return Just((token, false))
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        
        #if DEBUG
        print("🟡 Kakao idToken: \(request.idToken.prefix(20))...")
        if let jsonData = try? JSONEncoder().encode(request),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🟡 Request body: \(jsonString)")
        }
        #endif
        
        let publisher: AnyPublisher<KakaoLoginResponse, APIClientError> = apiClient.request(
            path: "api/oauth/login/kakao",
            method: .post,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return publisher
            .mapError(AuthRepository.mapAPIError(_:))
            .tryMap { response -> (KeychainToken, Bool) in
                guard let data = response.data else {
                    throw AuthError.serverError(response.message)
                }
                
                #if DEBUG
                print("✅ 카카오 로그인 서버 응답 성공:")
                print("   accessToken: \(data.accessToken.prefix(20))...")
                print("   refreshToken: \(data.refreshToken.prefix(20))...")
                print("   isExistMember: \(data.isExistMember)")
                #endif
                
                let token = KeychainToken(
                    accessToken: data.accessToken,
                    refreshToken: data.refreshToken
                )
                
                return (token, data.isExistMember)
            }
            .mapError { $0 as? AuthError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Apple Login
    public func loginWithApple(request: AppleLoginRequest) -> AnyPublisher<(KeychainToken, Bool), AuthError> {
        if MockConfig.useMockData {
            #if DEBUG
            print("🍎 Using mock Apple login")
            #endif
            let token = KeychainToken(
                accessToken: "mock_apple_access_token_\(UUID().uuidString)",
                refreshToken: "mock_apple_refresh_token_\(UUID().uuidString)",
                expiresIn: 3600
            )
            return Just((token, true))
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        
        #if DEBUG
        print("🍎 identityToken: \(request.identityToken)")
        if let jsonData = try? JSONEncoder().encode(request),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("🍎 Request body: \(jsonString)")
        }
        #endif
        
        let publisher: AnyPublisher<AppleLoginResponse, APIClientError> = apiClient.request(
            path: "api/oauth/login/apple",
            method: .post,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return publisher
            .mapError(AuthRepository.mapAPIError(_:))
            .tryMap { response -> (KeychainToken, Bool) in
                guard response.isSuccess else {
                    throw AuthError.appleError(response.message)
                }
                guard let result = response.data else {
                    throw AuthError.decodingError("토큰 정보가 비어 있습니다.")
                }
                
                #if DEBUG
                print("✅ 애플 로그인 서버 응답 성공:")
                print("   accessToken: \(result.accessToken.prefix(20))...")
                print("   refreshToken: \(result.refreshToken.prefix(20))...")
                print("   isExistMember: \(result.isExistMember)")
                #endif
                
                let token = KeychainToken(
                    accessToken: result.accessToken,
                    refreshToken: result.refreshToken
                )
                
                return (token, result.isExistMember)
            }
            .mapError { $0 as? AuthError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sign Up
    public func signUp(request: SignUpRequest) -> AnyPublisher<KeychainToken, AuthError> {
        if MockConfig.useMockData {
            #if DEBUG
            print("📝 Using mock sign up")
            #endif
            let token = KeychainToken(
                accessToken: "mock_signup_access_token_\(UUID().uuidString)",
                refreshToken: "mock_signup_refresh_token_\(UUID().uuidString)",
                expiresIn: 3600
            )
            return Just(token)
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let token = KeychainToken(
                    accessToken: "mock_access_token",
                    refreshToken: "mock_refresh_token"
                )
                promise(.success(token))
            }
        }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sign Up Simplified (약관 동의만) - Mock Only
    public func signUpSimplified(request: SignUpSimplifiedRequest) -> AnyPublisher<KeychainToken, AuthError> {
        // Mock 데이터로만 동작 (API 연결 없음)
        #if DEBUG
        print("📝 Mock simplified sign up (marketing: \(request.marketingAgreed))")
        #endif
        
        let token = KeychainToken(
            accessToken: "mock_signup_simplified_access_token_\(UUID().uuidString)",
            refreshToken: "mock_signup_simplified_refresh_token_\(UUID().uuidString)",
            expiresIn: 3600
        )
        
        return Just(token)
            .delay(for: .milliseconds(800), scheduler: DispatchQueue.main)
            .setFailureType(to: AuthError.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Logout Kakao
    public func logoutKakao() -> AnyPublisher<Void, AuthError> {
        if MockConfig.useMockData {
            #if DEBUG
            print("🚪 Using mock Kakao logout")
            #endif
            return Just(())
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        
        #if DEBUG
        print("🚪 Logging out from Kakao account...")
        #endif
        
        // 로그아웃은 인증이 필요하므로 interceptor를 사용 (APIClient의 session에 이미 설정됨)
        let publisher: AnyPublisher<LogoutKakaoResponse, APIClientError> = apiClient.request(
            path: "api/oauth/logout/kakao",
            method: .post,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return publisher
            .mapError(AuthRepository.mapAPIError(_:))
            .tryMap { response -> Void in
                #if DEBUG
                print("🔄 로그아웃 응답: statusCode=\(response.statusCode), code=\(response.code), message=\(response.message)")
                #endif
                
                // statusCode가 200이면 성공
                guard response.statusCode == 200 else {
                    throw AuthError.serverError(response.message)
                }
                
                #if DEBUG
                print("✅ 카카오 로그아웃 성공: \(response.message)")
                #endif
                
                return ()
            }
            .mapError { $0 as? AuthError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Revoke Kakao
    public func revokeKakao() -> AnyPublisher<Void, AuthError> {
        if MockConfig.useMockData {
            #if DEBUG
            print("🚪 Using mock Kakao revoke")
            #endif
            return Just(())
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        
        #if DEBUG
        print("🚪 Revoking Kakao account...")
        #endif
        
        // 탈퇴는 인증이 필요하므로 interceptor를 사용 (APIClient의 session에 이미 설정됨)
        // interceptor를 nil로 전달하면 Session의 기본 interceptor가 사용됨
        let publisher: AnyPublisher<RevokeKakaoResponse, APIClientError> = apiClient.request(
            path: "api/oauth/unlink/kakao",
            method: .post,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return publisher
            .mapError(AuthRepository.mapAPIError(_:))
            .tryMap { response -> Void in
                #if DEBUG
                print("🔄 탈퇴 응답: statusCode=\(response.statusCode), code=\(response.code), message=\(response.message)")
                #endif
                
                // statusCode가 200이면 성공
                guard response.statusCode == 200 else {
                    throw AuthError.serverError(response.message)
                }
                
                #if DEBUG
                print("✅ 카카오 탈퇴 성공: \(response.message)")
                #endif
                
                return ()
            }
            .mapError { $0 as? AuthError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Revoke Apple
    public func revokeApple() -> AnyPublisher<Void, AuthError> {
        if MockConfig.useMockData {
            #if DEBUG
            print("🚪 Using mock Apple revoke")
            #endif
            return Just(())
                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
                .setFailureType(to: AuthError.self)
                .eraseToAnyPublisher()
        }
        
        #if DEBUG
        print("🚪 Revoking Apple account...")
        #endif
        
        // 애플 탈퇴 API 호출 (응답 data는 String 타입)
        let publisher: AnyPublisher<RevokeAppleResponse, APIClientError> = apiClient.request(
            path: "api/oauth/unlink/apple",
            method: .post,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return publisher
            .mapError(AuthRepository.mapAPIError(_:))
            .tryMap { response -> Void in
                #if DEBUG
                print("🔄 탈퇴 응답: statusCode=\(response.statusCode), code=\(response.code), message=\(response.message)")
                if let data = response.data {
                    print("   data: \(data)")
                }
                #endif
                
                // statusCode가 200이면 성공 (애플은 statusCode 0도 성공일 수 있음)
                guard response.statusCode == 200 || response.statusCode == 0 else {
                    throw AuthError.serverError(response.message)
                }
                
                #if DEBUG
                print("✅ 애플 탈퇴 성공: \(response.message)")
                #endif
                
                return ()
            }
            .mapError { $0 as? AuthError ?? .unknownError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}

// MARK: - Helpers
private extension AuthRepository {
    struct APIErrorResponse: Decodable {
        let statusCode: Int?
        let code: String?
        let message: String
    }
    
    static func mapAPIError(_ error: APIClientError) -> AuthError {
        switch error {
        case .invalidURL:
            return .networkError
        case .http(let statusCode, let data):
            if let authError = parseAPIError(data: data) {
                return authError
            }
            return .httpError(statusCode: statusCode)
        case .decoding(let message, let data):
            if let authError = parseAPIError(data: data) {
                return authError
            }
            return .decodingError(message)
        case .network:
            return .networkError
        }
    }
    
    static func parseAPIError(data: Data?) -> AuthError? {
        guard
            let data,
            let response = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
        else {
            return nil
        }
        
        if response.message.isEmpty == false {
            return .serverError(response.message)
        }
        return nil
    }
}
