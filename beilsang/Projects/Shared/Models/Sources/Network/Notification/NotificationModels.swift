//
//  NotificationModels.swift
//  ModelsShared
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation

// MARK: - 알림 목록 조회
public struct NotificationListRequest: Codable {
    public let page: Int
    public let size: Int
    
    public init(page: Int, size: Int = 20) {
        self.page = page
        self.size = size
    }
}

public struct NotificationListResponse: Codable {
    public let notifications: [NotificationDTO]
    public let hasNext: Bool
    public let totalCount: Int
    
    public init(notifications: [NotificationDTO], hasNext: Bool, totalCount: Int) {
        self.notifications = notifications
        self.hasNext = hasNext
        self.totalCount = totalCount
    }
}

public struct NotificationDTO: Codable {
    public let notificationId: String
    public let type: String
    public let title: String
    public let message: String
    public let createdAt: String
    public let isRead: Bool
    public let relatedId: String?
    
    public init(
        notificationId: String,
        type: String,
        title: String,
        message: String,
        createdAt: String,
        isRead: Bool,
        relatedId: String? = nil
    ) {
        self.notificationId = notificationId
        self.type = type
        self.title = title
        self.message = message
        self.createdAt = createdAt
        self.isRead = isRead
        self.relatedId = relatedId
    }
}

// MARK: - 알림 읽음 처리
public struct MarkNotificationReadRequest: Codable {
    public let notificationIds: [String]
    
    public init(notificationIds: [String]) {
        self.notificationIds = notificationIds
    }
}

public struct MarkNotificationReadResponse: Codable {
    public let success: Bool
    
    public init(success: Bool) {
        self.success = success
    }
}

// MARK: - 알림 삭제
public struct DeleteNotificationRequest: Codable {
    public let notificationIds: [String]
    
    public init(notificationIds: [String]) {
        self.notificationIds = notificationIds
    }
}

public struct DeleteNotificationResponse: Codable {
    public let success: Bool
    
    public init(success: Bool) {
        self.success = success
    }
}

// MARK: - 알림 전체 삭제
public struct DeleteAllNotificationsResponse: Codable {
    public let success: Bool
    
    public init(success: Bool) {
        self.success = success
    }
}







