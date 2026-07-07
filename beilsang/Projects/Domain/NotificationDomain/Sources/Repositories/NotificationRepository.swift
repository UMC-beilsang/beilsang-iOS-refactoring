//
//  NotificationRepository.swift
//  NotificationDomain
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation
import ModelsShared
import NetworkCore
import Alamofire

public final class NotificationRepository: NotificationRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    public init(baseURL: String) {
        self.apiClient = APIClient(baseURL: baseURL)
    }
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Fetch Notifications
    public func fetchNotifications(page: Int, size: Int) async throws -> NotificationListResponse {
        let response: APIResponse<NotificationListResponse> = try await apiClient.request(
            path: "api/notifications?page=\(page)&size=\(size)",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard let data = response.data else {
            throw APIClientError.decoding("Response data is nil", nil)
        }
        
        return data
    }
    
    // MARK: - Mark As Read
    public func markAsRead(notificationIds: [String]) async throws -> Bool {
        let request = MarkNotificationReadRequest(notificationIds: notificationIds)
        
        let response: APIResponse<MarkNotificationReadResponse> = try await apiClient.request(
            path: "api/notifications/read",
            method: .post,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard let data = response.data else {
            throw APIClientError.decoding("Response data is nil", nil)
        }
        
        return data.success
    }
    
    // MARK: - Delete Notifications
    public func deleteNotifications(notificationIds: [String]) async throws -> Bool {
        let request = DeleteNotificationRequest(notificationIds: notificationIds)
        
        let response: APIResponse<DeleteNotificationResponse> = try await apiClient.request(
            path: "api/notifications",
            method: .delete,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard let data = response.data else {
            throw APIClientError.decoding("Response data is nil", nil)
        }
        
        return data.success
    }
    
    // MARK: - Delete All Notifications
    public func deleteAllNotifications() async throws -> Bool {
        let response: APIResponse<DeleteAllNotificationsResponse> = try await apiClient.request(
            path: "api/notifications/all",
            method: .delete,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard let data = response.data else {
            throw APIClientError.decoding("Response data is nil", nil)
        }
        
        return data.success
    }
}
