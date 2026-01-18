//
//  FetchNotificationsUseCase.swift
//  NotificationDomain
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation
import ModelsShared

public final class FetchNotificationsUseCase {
    private let repository: NotificationRepositoryProtocol
    
    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(page: Int, size: Int = 20) async throws -> ([ModelsShared.Notification], Bool) {
        let response = try await repository.fetchNotifications(page: page, size: size)
        
        // DTO를 Domain 모델로 변환
        let notifications = response.notifications.compactMap { dto -> ModelsShared.Notification? in
            guard let type = NotificationType(rawValue: dto.type),
                  let createdAt = ISO8601DateFormatter().date(from: dto.createdAt) else {
                return nil
            }
            
            return ModelsShared.Notification(
                id: dto.notificationId,
                type: type,
                title: dto.title,
                message: dto.message,
                createdAt: createdAt,
                isRead: dto.isRead,
                relatedId: dto.relatedId
            )
        }
        
        return (notifications, response.hasNext)
    }
}







