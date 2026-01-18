//
//  DeleteNotificationsUseCase.swift
//  NotificationDomain
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation

public final class DeleteNotificationsUseCase {
    private let repository: NotificationRepositoryProtocol
    
    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(notificationIds: [String]) async throws -> Bool {
        return try await repository.deleteNotifications(notificationIds: notificationIds)
    }
}







