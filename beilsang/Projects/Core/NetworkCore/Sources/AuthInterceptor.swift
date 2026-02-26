//
//  AuthInterceptor.swift
//  NetworkCore
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import Alamofire
import Combine
import ModelsShared
import StorageCore

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
    /// 모든 요청에 자동으로 토큰 추가
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        
        // Keychain에서 토큰 가져오기
        var cancellable: AnyCancellable?
        cancellable = tokenStorage.getToken()
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        #if DEBUG
                        print("🔑 Failed to get token: \(error)")
                        #endif
                        // 토큰 없어도 요청은 진행 (로그인 API 등은 토큰 불필요)
                        completion(.success(urlRequest))
                    }
                    cancellable?.cancel()
                },
                receiveValue: { token in
                    if let token = token {
                        // 토큰이 있으면 Authorization 헤더 추가
                        // 만료 여부는 서버에서 401로 응답할 때 처리
                        urlRequest.setValue(
                            "\(token.tokenType) \(token.accessToken)",
                            forHTTPHeaderField: "Authorization"
                        )
                        #if DEBUG
                        print("🔑 Token added to request: \(urlRequest.url?.path ?? "")")
                        #endif
                    }
                    // 토큰이 없어도 요청은 진행 (로그인 API 등은 토큰 불필요)
                    completion(.success(urlRequest))
                    cancellable?.cancel()
                }
            )
    }
    
    // MARK: - RequestRetrier
    /// 401 에러 발생 시 토큰 갱신 후 재시도
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            // 401 에러가 아니면 재시도 안 함
            completion(.doNotRetryWithError(error))
            return
        }
        
        #if DEBUG
        print("🔄 Received 401, attempting token refresh")
        #endif
        
        // 이미 갱신 중이면 대기열에 추가
        requestsToRetry.append(completion)
        
        guard !isRefreshing else {
            #if DEBUG
            print("🔄 Token refresh already in progress, waiting...")
            #endif
            return
        }
        
        isRefreshing = true
        
        // 토큰 갱신 시도
        var cancellable: AnyCancellable?
        cancellable = tokenStorage.getToken()
            .mapError { error -> Error in
                #if DEBUG
                print("❌ Failed to get token from storage: \(error)")
                #endif
                return error as Error
            }
            .flatMap { [weak self] token -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "AuthInterceptor", code: -1, userInfo: [NSLocalizedDescriptionKey: "AuthInterceptor deallocated"]))
                        .eraseToAnyPublisher()
                }
                
                guard let token = token else {
                    #if DEBUG
                    print("❌ No token found in storage, cannot refresh")
                    #endif
                    // 토큰이 없으면 재발급 불가능 - 모든 요청 실패 처리
                    return Fail(error: NSError(domain: "AuthInterceptor", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token found in storage"]))
                        .eraseToAnyPublisher()
                }
                
                #if DEBUG
                print("🔄 Found refresh token, attempting refresh...")
                #endif
                
                // 토큰 재발급 API 호출
                return self.refreshToken(refreshToken: token.refreshToken)
            }
            .sink(
                receiveCompletion: { [weak self] result in
                    guard let self = self else { return }
                    
                    self.isRefreshing = false
                    
                    switch result {
                    case .finished:
                        #if DEBUG
                        print("✅ Token refreshed successfully, retrying \(self.requestsToRetry.count) requests")
                        #endif
                        // 대기 중인 모든 요청 재시도
                        self.requestsToRetry.forEach { $0(.retry) }
                        self.requestsToRetry.removeAll()
                        
                    case .failure(let error):
                        #if DEBUG
                        print("❌ Token refresh failed: \(error.localizedDescription)")
                        #endif
                        // 갱신 실패 시 모든 요청 실패 처리
                        self.requestsToRetry.forEach { $0(.doNotRetryWithError(error)) }
                        self.requestsToRetry.removeAll()
                        
                        // 토큰 재발급 실패 시 토큰 삭제 (로그아웃 처리)
                        // 단, 토큰이 없어서 실패한 경우는 이미 삭제된 상태이므로 다시 삭제할 필요 없음
                        if (error as NSError).code != -1 {
                            #if DEBUG
                            print("🗑️ Deleting token due to refresh failure")
                            #endif
                            _ = self.tokenStorage.deleteToken()
                                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                        }
                    }
                    
                    cancellable?.cancel()
                },
                receiveValue: { _ in }
            )
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
    
    /// 토큰 재발급 API 호출
    /// - Parameter refreshToken: 리프레시 토큰
    /// - Returns: 성공/실패 Publisher
    private func refreshToken(refreshToken: String) -> AnyPublisher<Void, Error> {
        #if DEBUG
        print("🔄 Refreshing token...")
        #endif
        
        // URL 구성 (APIClient의 normalize 로직과 동일하게)
        let normalizedBaseURL = Self.normalize(baseURL: baseURL)
        let urlString = normalizedBaseURL.hasSuffix("/") ? "\(normalizedBaseURL)api/oauth/refresh" : "\(normalizedBaseURL)/api/oauth/refresh"
        guard let url = URL(string: urlString) else {
            return Fail(error: NSError(
                domain: "AuthInterceptor",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"]
            ))
            .eraseToAnyPublisher()
        }
        
        // Request 생성
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        
        return Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AuthInterceptor", code: -1, userInfo: [NSLocalizedDescriptionKey: "AuthInterceptor deallocated"])))
                return
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            
            do {
                urlRequest.httpBody = try JSONEncoder().encode(request)
            } catch {
                promise(.failure(error))
                return
            }
            
            URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    #if DEBUG
                    print("❌ Token refresh network error: \(error)")
                    #endif
                    promise(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    promise(.failure(NSError(
                        domain: "AuthInterceptor",
                        code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid response"]
                    )))
                    return
                }
                
                guard httpResponse.statusCode == 200, let data = data else {
                    #if DEBUG
                    print("❌ Token refresh failed with status code: \(httpResponse.statusCode)")
                    if let data = data, let body = String(data: data, encoding: .utf8) {
                        print("   Response body: \(body)")
                    }
                    #endif
                    promise(.failure(NSError(
                        domain: "AuthInterceptor",
                        code: -5,
                        userInfo: [NSLocalizedDescriptionKey: "Token refresh failed with status code: \(httpResponse.statusCode)"]
                    )))
                    return
                }
                
                do {
                    let refreshResponse = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
                    
                    guard refreshResponse.statusCode == 200, let data = refreshResponse.data else {
                        promise(.failure(NSError(
                            domain: "AuthInterceptor",
                            code: -6,
                            userInfo: [NSLocalizedDescriptionKey: refreshResponse.message]
                        )))
                        return
                    }
                    
                    #if DEBUG
                    print("✅ Token refresh successful")
                    print("   New accessToken: \(data.accessToken.prefix(20))...")
                    print("   New refreshToken: \(data.refreshToken.prefix(20))...")
                    #endif
                    
                    // 기존 토큰의 provider 정보 가져오기
                    var saveCancellable: AnyCancellable?
                    saveCancellable = self.tokenStorage.getToken()
                        .mapError { $0 as Error }
                        .flatMap { existingToken -> AnyPublisher<Void, Error> in
                            // 새로운 토큰을 Keychain에 저장 (기존 provider 유지)
                            let newToken = KeychainToken(
                                accessToken: data.accessToken,
                                refreshToken: data.refreshToken,
                                provider: existingToken?.provider // 기존 provider 유지
                            )
                            
                            return self.tokenStorage.saveToken(newToken)
                                .mapError { $0 as Error }
                                .eraseToAnyPublisher()
                        }
                        .sink(
                            receiveCompletion: { saveResult in
                                switch saveResult {
                                case .finished:
                                    #if DEBUG
                                    print("✅ Refreshed token saved to keychain")
                                    #endif
                                    promise(.success(()))
                                case .failure(let error):
                                    #if DEBUG
                                    print("❌ Failed to save refreshed token: \(error)")
                                    #endif
                                    promise(.failure(error))
                                }
                                saveCancellable?.cancel()
                            },
                            receiveValue: { _ in }
                        )
                } catch {
                    #if DEBUG
                    print("❌ Token refresh decode error: \(error)")
                    if let body = String(data: data, encoding: .utf8) {
                        print("   Response body: \(body)")
                    }
                    #endif
                    promise(.failure(error))
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }
}
