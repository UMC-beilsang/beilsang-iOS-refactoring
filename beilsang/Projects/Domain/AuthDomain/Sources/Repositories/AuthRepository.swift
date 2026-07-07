//
//  AuthRepository.swift
//  AuthData
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import ModelsShared
import NetworkCore
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
    public func checkNickname(_ nickname: String) async throws -> Bool {
        guard !nickname.isEmpty else {
            throw AuthError.serverError("닉네임이 올바르지 않습니다.")
        }
        
        guard let encoded = nickname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw AuthError.serverError("닉네임 인코딩 실패")
        }
        
        let response: APIResponse<String> = try await apiClient.request(
            path: "api/oauth/nickname?nickname=\(encoded)",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        switch response.statusCode {
        case 200: return true
        case 400: return false
        default: throw AuthError.serverError(response.message)
        }
    }
    
    // MARK: - Kakao Login
    public func loginWithKakao(request: KakaoLoginRequest) async throws -> (KeychainToken, Bool) {
        #if DEBUG
        print("📤 Sending Kakao Login Request:")
        print("   idToken (first 50 chars): \(request.idToken.prefix(50))...")
        #endif
        
        let response: KakaoLoginResponse = try await apiClient.request(
            path: "api/oauth/login/kakao",
            method: .post,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard let data = response.data else {
            throw AuthError.serverError(response.message)
        }
        
        let token = KeychainToken(
            accessToken: data.accessToken,
            refreshToken: data.refreshToken
        )
        
        return (token, data.isTermsAgreed)
    }
    
    // MARK: - Apple Login
    public func loginWithApple(request: AppleLoginRequest) async throws -> (KeychainToken, Bool) {
        let (envelope, responseHeaders): (AppleLoginEnvelope, HTTPHeaders) = try await apiClient.requestReturningHeaders(
            path: "api/oauth/login/apple",
            method: .post,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )

        #if DEBUG
        print("🍎 Apple login response headers: \(responseHeaders.dictionary)")
        print("🍎 Apple login envelope: success=\(envelope.success), code=\(envelope.code ?? "nil"), message=\(envelope.resolvedMessage)")
        #endif

        guard envelope.success else {
            throw AuthError.serverError(envelope.resolvedMessage)
        }

        // 토큰은 바디(data) 또는 응답 헤더로 내려올 수 있으므로 둘 다 확인한다.
        let accessToken = AuthRepository.nonEmpty(envelope.data?.accessToken)
            ?? AuthRepository.headerValue(responseHeaders, ["Authorization", "accessToken", "AccessToken", "access-token", "Access-Token"])
                .map { $0.replacingOccurrences(of: "Bearer ", with: "").trimmingCharacters(in: .whitespaces) }

        let refreshToken = AuthRepository.nonEmpty(envelope.data?.refreshToken)
            ?? AuthRepository.headerValue(responseHeaders, ["refreshToken", "RefreshToken", "Refresh-Token", "refresh-token", "Refresh"])
            ?? ""

        guard let accessToken, !accessToken.isEmpty else {
            #if DEBUG
            print("❌ Apple login: accessToken을 바디/헤더 어디에서도 찾지 못했습니다.")
            #endif
            throw AuthError.serverError("로그인 토큰을 받지 못했습니다.")
        }

        let token = KeychainToken(
            accessToken: accessToken,
            refreshToken: refreshToken
        )

        return (token, envelope.data?.isTermsAgreed ?? false)
    }

    // 여러 후보 헤더 이름을 대소문자 구분 없이 조회 (Alamofire HTTPHeaders는 case-insensitive)
    private static func headerValue(_ headers: HTTPHeaders, _ names: [String]) -> String? {
        for name in names {
            if let value = headers.value(for: name), !value.isEmpty {
                return value
            }
        }
        return nil
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
    
    // MARK: - Sign Up Simplified (약관 동의)
    public func signUpSimplified(agreed: Bool) async throws {
        let request = SignUpSimplifiedRequest(agreed: agreed)
        let response: APIResponse<String> = try await apiClient.request(
            path: "api/terms/agree",
            method: .post,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )

        guard response.statusCode == 200 else {
            throw AuthError.serverError(response.message)
        }
    }
    
    // MARK: - Logout Kakao
    public func logoutKakao() async throws {
        let response: LogoutKakaoResponse = try await apiClient.request(
            path: "api/oauth/logout/kakao",
            method: .post,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard response.statusCode == 200 else {
            throw AuthError.serverError(response.message)
        }
    }
    
    // MARK: - Revoke Kakao
    public func revokeKakao() async throws {
        let response: RevokeKakaoResponse = try await apiClient.request(
            path: "api/oauth/unlink/kakao",
            method: .post,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard response.statusCode == 200 else {
            throw AuthError.serverError(response.message)
        }
    }
    
    // MARK: - Revoke Apple
    public func revokeApple() async throws {
        let response: RevokeAppleResponse = try await apiClient.request(
            path: "api/oauth/unlink/apple",
            method: .post,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard response.statusCode == 200 || response.statusCode == 0 else {
            throw AuthError.serverError(response.message)
        }
    }
    
    // MARK: - Error Mapping
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
    
    private static func parseAPIError(data: Data?) -> AuthError? {
        guard let data,
              let response = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
        else {
            return nil
        }
        
        return response.message.isEmpty ? nil : .serverError(response.message)
    }
    
    private struct APIErrorResponse: Decodable {
        let statusCode: Int?
        let code: String?
        let message: String
    }
}
