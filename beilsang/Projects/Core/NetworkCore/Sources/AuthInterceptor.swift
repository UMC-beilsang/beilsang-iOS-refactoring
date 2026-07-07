//
//  AuthInterceptor.swift
//  NetworkCore
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import Alamofire
import ModelsShared
@preconcurrency import StorageCore

public extension NSNotification.Name {
    /// 리프레시 토큰까지 만료되어 재로그인이 필요할 때 발생
    static let authSessionExpired = NSNotification.Name("AuthSessionExpired")
}

/// 모든 API 요청에 자동으로 토큰을 추가하고, 401 에러 시 토큰 재발급을 처리하는 인터셉터
public final class AuthInterceptor: RequestInterceptor {
    private let tokenStorage: KeychainTokenStorageProtocol
    private let baseURL: String
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    public init(tokenStorage: KeychainTokenStorageProtocol, baseURL: String) {
        self.tokenStorage = tokenStorage
        self.baseURL = baseURL
    }
    
    // MARK: - RequestAdapter
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        
        let path = urlRequest.url?.path ?? ""
        let noAuthPaths = [
            "/api/oauth/login/kakao",
            "/api/oauth/login/apple",
            "/api/oauth/refresh",
            "/api/oauth/nickname"
        ]
        
        if noAuthPaths.contains(where: { path.contains($0) }) {
            completion(.success(urlRequest))
            return
        }
        
        Task {
            do {
                let token = try await tokenStorage.getToken()
                
                if let token = token {
                    urlRequest.setValue(
                        "\(token.tokenType) \(token.accessToken)",
                        forHTTPHeaderField: "Authorization"
                    )
                }
                
                completion(.success(urlRequest))
            } catch {
                completion(.success(urlRequest))
            }
        }
    }
    
    // MARK: - RequestRetrier
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        requestsToRetry.append(completion)
        
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        
        Task {
            do {
                let token = try await tokenStorage.getToken()
                
                guard let token = token else {
                    throw NSError(domain: "AuthInterceptor", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token found in storage"])
                }
                
                try await refreshToken(refreshToken: token.refreshToken)
                
                await MainActor.run {
                    self.isRefreshing = false
                    self.requestsToRetry.forEach { $0(.retry) }
                    self.requestsToRetry.removeAll()
                }
            } catch {
                await MainActor.run {
                    self.isRefreshing = false
                    self.requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
                    self.requestsToRetry.removeAll()
                }
                
                let errorCode = (error as NSError).code
                // -1: 토큰 없음, -5: 리프레시 토큰 만료(401), -6: 서버 에러
                let isSessionExpired = (errorCode == -1 || errorCode == -5 || errorCode == -6)
                
                if errorCode != -1 {
                    try? await self.tokenStorage.deleteToken()
                }
                
                if isSessionExpired {
#if DEBUG
                    print("🔒 세션 만료 - 로그인 화면으로 이동 (code: \(errorCode))")
#endif
                    NotificationCenter.default.post(name: .authSessionExpired, object: nil)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// URL 정규화 (APIClient와 동일한 로직)
    private static func normalize(baseURL: String) -> String {
        var url = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !url.isEmpty else { return "" }
        
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            url = "https://" + url
        }
        if url.hasSuffix("/") {
            url.removeLast()
        }
        return url
    }
    
    private func refreshToken(refreshToken: String) async throws {
        let normalizedBaseURL = Self.normalize(baseURL: baseURL)
        let urlString = normalizedBaseURL.hasSuffix("/") ? "\(normalizedBaseURL)api/oauth/refresh" : "\(normalizedBaseURL)/api/oauth/refresh"
        guard let url = URL(string: urlString) else {
            throw NSError(
                domain: "AuthInterceptor",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"]
            )
        }
        
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(
                domain: "AuthInterceptor",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Invalid response"]
            )
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(
                domain: "AuthInterceptor",
                code: -5,
                userInfo: [NSLocalizedDescriptionKey: "Token refresh failed with status code: \(httpResponse.statusCode)"]
            )
        }
        
        let refreshResponse = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
        
        guard refreshResponse.statusCode == 200, let data = refreshResponse.data else {
            throw NSError(
                domain: "AuthInterceptor",
                code: -6,
                userInfo: [NSLocalizedDescriptionKey: refreshResponse.message]
            )
        }
        
        let existingToken = try await tokenStorage.getToken()
        
        let newToken = KeychainToken(
            accessToken: data.accessToken,
            refreshToken: data.refreshToken,
            provider: existingToken?.provider
        )
        
        try await tokenStorage.saveToken(newToken)
    }
}
