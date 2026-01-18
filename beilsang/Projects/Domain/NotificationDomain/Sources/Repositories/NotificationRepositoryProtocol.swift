//
//  NotificationRepositoryProtocol.swift
//  NotificationDomain
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation
import ModelsShared

public protocol NotificationRepositoryProtocol {
    /// 알림 목록 조회
    func fetchNotifications(page: Int, size: Int) async throws -> NotificationListResponse
    
    /// 알림 읽음 처리
    func markAsRead(notificationIds: [String]) async throws -> Bool
    
    /// 알림 삭제
    func deleteNotifications(notificationIds: [String]) async throws -> Bool
    
    /// 전체 알림 삭제
    func deleteAllNotifications() async throws -> Bool
}







