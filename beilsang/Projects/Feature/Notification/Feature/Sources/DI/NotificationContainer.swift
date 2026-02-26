//
//  NotificationContainer.swift
//  NotificationFeature
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation
import Alamofire
import StorageCore
import NetworkCore
import NotificationDomain

@MainActor
public final class NotificationContainer {
    // MARK: - Properties
    private let baseURL: String
    private let tokenStorage: KeychainTokenStorageProtocol
    private let notificationRepository: NotificationRepositoryProtocol
    
    // MARK: - Designated Init
    public init(baseURL: String, tokenStorage: KeychainTokenStorageProtocol = KeychainTokenStorage()) {
        self.baseURL = baseURL
        self.tokenStorage = tokenStorage
        
        // AuthInterceptor로 토큰 자동 추가
        let interceptor = AuthInterceptor(tokenStorage: tokenStorage, baseURL: baseURL)
        let session = Session(interceptor: interceptor)
        let apiClient = APIClient(baseURL: baseURL, session: session)
        
        // Repository 초기화
        self.notificationRepository = NotificationRepository(apiClient: apiClient)
    }
    
    // MARK: - Convenience Init
    public convenience init() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        self.init(baseURL: baseURL)
    }
    
    // MARK: - Factory Methods
    public func makeNotificationViewModel() -> NotificationViewModel {
        // UseCases 생성
        let fetchNotificationsUseCase = FetchNotificationsUseCase(repository: notificationRepository)
        let markAsReadUseCase = MarkNotificationAsReadUseCase(repository: notificationRepository)
        let deleteNotificationsUseCase = DeleteNotificationsUseCase(repository: notificationRepository)
        let deleteAllNotificationsUseCase = DeleteAllNotificationsUseCase(repository: notificationRepository)
        
        // ViewModel 생성
        return NotificationViewModel(
            fetchNotificationsUseCase: fetchNotificationsUseCase,
            markAsReadUseCase: markAsReadUseCase,
            deleteNotificationsUseCase: deleteNotificationsUseCase,
            deleteAllNotificationsUseCase: deleteAllNotificationsUseCase
        )
    }
}

// MARK: - Preview Mock
extension NotificationContainer {
    public static var mock: NotificationContainer {
        NotificationContainer(baseURL: "https://mock.api.com")
    }
}

