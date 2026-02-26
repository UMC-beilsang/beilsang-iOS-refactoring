//
//  AuthContainer.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import Alamofire
import AuthDomain
import StorageCore
import NetworkCore

@MainActor
public final class AuthContainer: ObservableObject {
    // MARK: - Repositories
    public lazy var authRepository: AuthRepositoryProtocol = {
        let interceptor = AuthInterceptor(tokenStorage: tokenStorage, baseURL: baseURL)
        let session = Session(interceptor: interceptor)
        let apiClient = APIClient(baseURL: baseURL, session: session)
        return AuthRepository(apiClient: apiClient)
    }()

    // MARK: - Use Cases
    public lazy var signUpUseCase: SignUpUseCaseProtocol = {
        SignUpUseCase(repository: authRepository, tokenStorage: tokenStorage)
    }()

    public lazy var kakaoLoginUseCase: KakaoLoginUseCaseProtocol = {
        KakaoLoginUseCase(repository: authRepository, tokenStorage: tokenStorage)
    }()

    public lazy var appleLoginUseCase: AppleLoginUseCaseProtocol = {
        AppleLoginUseCase(repository: authRepository, tokenStorage: tokenStorage)
    }()

    public lazy var logoutUseCase: LogoutUseCaseProtocol = {
        LogoutUseCase(repository: authRepository, tokenStorage: tokenStorage)
    }()

    public lazy var revokeUseCase: RevokeUseCaseProtocol = {
        RevokeUseCase(repository: authRepository, tokenStorage: tokenStorage)
    }()

    // MARK: - Configuration
    public let baseURL: String
    public let tokenStorage: KeychainTokenStorageProtocol

    // MARK: - Designated Init
    public init(
        baseURL: String,
        tokenStorage: KeychainTokenStorageProtocol = KeychainTokenStorage()
    ) {
        self.baseURL = Self.normalizeURL(baseURL)
        self.tokenStorage = tokenStorage
    }

    // MARK: - Convenience Init
    public convenience init() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        self.init(baseURL: baseURL)
    }
    
    // MARK: - URL Normalization
    private static func normalizeURL(_ url: String) -> String {
        var normalized = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !normalized.isEmpty else { return "" }
        
        // https:// 스킴 추가
        if !normalized.hasPrefix("http://") && !normalized.hasPrefix("https://") {
            normalized = "https://" + normalized
        }
        
        // 마지막 슬래시 제거
        if normalized.hasSuffix("/") {
            normalized.removeLast()
        }
        
        return normalized
    }
}
