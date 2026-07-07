//
//  DiscoverContainer.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/8/25.
//

import Foundation
import Alamofire
import ChallengeDomain
import StorageCore
import NetworkCore

@MainActor
public final class DiscoverContainer {
    public let discoverViewModel: DiscoverViewModel
    public let coordinator: DiscoverCoordinator
    
    public init(baseURL: String, tokenStorage: KeychainTokenStorageProtocol = KeychainTokenStorage()) {
        let interceptor = AuthInterceptor(tokenStorage: tokenStorage, baseURL: baseURL)
        let session = Session(interceptor: interceptor)
        let apiClient = APIClient(baseURL: baseURL, session: session)
        let discoverRepo = DiscoverRepository(apiClient: apiClient)
        
        self.discoverViewModel = DiscoverViewModel(repository: discoverRepo)
        self.coordinator = DiscoverCoordinator()
    }
    
    /// 기본 초기화 - Bundle에서 BASE_URL을 가져와서 사용
    public convenience init() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        self.init(baseURL: baseURL)
    }
}
