//
//  AuthContainer.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import AuthDomain
import NetworkCore
import StorageCore

@MainActor
public final class AuthContainer: ObservableObject {
    // MARK: - Repositories
    private lazy var authRepository: AuthRepositoryProtocol = AuthRepositoryImpl(
        networkService: authNetworkService,
        tokenStorage: tokenStorage
    )

    // MARK: - Network
    private let authNetworkService: AuthNetworkServiceProtocol

    // MARK: - Storage
    private lazy var tokenStorage: KeychainTokenStorageProtocol = KeychainTokenStorage()

    // MARK: - Use Cases
    lazy var kakaoLoginUseCase: KakaoLoginUseCaseProtocol = KakaoLoginUseCase(repository: authRepository)
    lazy var appleLoginUseCase: AppleLoginUseCaseProtocol = AppleLoginUseCase(repository: authRepository)
    lazy var signUpUseCase: SignUpUseCaseProtocol = SignUpUseCase(repository: authRepository)

    // MARK: - Designated Init (App에서 주입)
    public init(baseURL: String) {
        self.authNetworkService = AuthNetworkService(baseURL: baseURL)
    }

    // MARK: - Convenience Init (Example 앱 등에서 사용)
    public convenience init() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        self.init(baseURL: baseURL)
    }
}
