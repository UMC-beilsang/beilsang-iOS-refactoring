//
//  NotificationRepository.swift
//  NotificationDomain
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation
import Combine
import ModelsShared
import NetworkCore
import UtilityShared
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
        if MockConfig.useMockData {
            #if DEBUG
            print("🔔 Using mock notifications")
            #endif
            // Mock 응답
            let mockNotifications = ModelsShared.Notification.mockData.map { notification in
                NotificationDTO(
                    notificationId: notification.id,
                    type: notification.type.rawValue,
                    title: notification.title,
                    message: notification.message,
                    createdAt: ISO8601DateFormatter().string(from: notification.createdAt),
                    isRead: notification.isRead,
                    relatedId: notification.relatedId
                )
            }
            
            return NotificationListResponse(
                notifications: mockNotifications,
                hasNext: false,
                totalCount: mockNotifications.count
            )
        }
        
        let path = "api/notifications?page=\(page)&size=\(size)"
        
        #if DEBUG
        print("🔔 Fetching notifications: GET /\(path)")
        #endif
        
        let publisher: AnyPublisher<APIResponse<NotificationListResponse>, APIClientError> = apiClient.request(
            path: path,
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard let data = response.data else {
                            continuation.resume(throwing: APIClientError.decoding("Response data is nil", nil))
                            return
                        }
                        continuation.resume(returning: data)
                    }
                )
        }
    }
    
    // MARK: - Mark As Read
    public func markAsRead(notificationIds: [String]) async throws -> Bool {
        if MockConfig.useMockData {
            #if DEBUG
            print("🔔 Mock: Mark notifications as read: \(notificationIds)")
            #endif
            return true
        }
        
        let path = "api/notifications/read"
        let request = MarkNotificationReadRequest(notificationIds: notificationIds)
        
        #if DEBUG
        print("🔔 Marking notifications as read: POST /\(path)")
        #endif
        
        let publisher: AnyPublisher<APIResponse<MarkNotificationReadResponse>, APIClientError> = apiClient.request(
            path: path,
            method: .post,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard let data = response.data else {
                            continuation.resume(throwing: APIClientError.decoding("Response data is nil", nil))
                            return
                        }
                        continuation.resume(returning: data.success)
                    }
                )
        }
    }
    
    // MARK: - Delete Notifications
    public func deleteNotifications(notificationIds: [String]) async throws -> Bool {
        if MockConfig.useMockData {
            #if DEBUG
            print("🔔 Mock: Delete notifications: \(notificationIds)")
            #endif
            return true
        }
        
        let path = "api/notifications"
        let request = DeleteNotificationRequest(notificationIds: notificationIds)
        
        #if DEBUG
        print("🔔 Deleting notifications: DELETE /\(path)")
        #endif
        
        let publisher: AnyPublisher<APIResponse<DeleteNotificationResponse>, APIClientError> = apiClient.request(
            path: path,
            method: .delete,
            body: request,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard let data = response.data else {
                            continuation.resume(throwing: APIClientError.decoding("Response data is nil", nil))
                            return
                        }
                        continuation.resume(returning: data.success)
                    }
                )
        }
    }
    
    // MARK: - Delete All Notifications
    public func deleteAllNotifications() async throws -> Bool {
        if MockConfig.useMockData {
            #if DEBUG
            print("🔔 Mock: Delete all notifications")
            #endif
            return true
        }
        
        let path = "api/notifications/all"
        
        #if DEBUG
        print("🔔 Deleting all notifications: DELETE /\(path)")
        #endif
        
        let publisher: AnyPublisher<APIResponse<DeleteAllNotificationsResponse>, APIClientError> = apiClient.request(
            path: path,
            method: .delete,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard let data = response.data else {
                            continuation.resume(throwing: APIClientError.decoding("Response data is nil", nil))
                            return
                        }
                        continuation.resume(returning: data.success)
                    }
                )
        }
    }
}

