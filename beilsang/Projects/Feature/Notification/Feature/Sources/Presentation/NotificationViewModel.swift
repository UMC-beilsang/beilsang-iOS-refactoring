//
//  NotificationViewModel.swift
//  NotificationFeature
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation
import ModelsShared
import NotificationDomain
import UIKit

@MainActor
public class NotificationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var notifications: [ModelsShared.Notification] = []
    @Published public var isLoading = false
    @Published public var isLoadingMore = false
    @Published public var hasMore = true
    @Published public var errorMessage: String?
    @Published public var showSettingsAlert = false
    
    // MARK: - Private Properties
    private var currentPage = 0
    private let pageSize = 20
    
    // Use Cases
    private let fetchNotificationsUseCase: FetchNotificationsUseCase
    private let markAsReadUseCase: MarkNotificationAsReadUseCase
    private let deleteNotificationsUseCase: DeleteNotificationsUseCase
    private let deleteAllNotificationsUseCase: DeleteAllNotificationsUseCase
    
    public init(
        fetchNotificationsUseCase: FetchNotificationsUseCase,
        markAsReadUseCase: MarkNotificationAsReadUseCase,
        deleteNotificationsUseCase: DeleteNotificationsUseCase,
        deleteAllNotificationsUseCase: DeleteAllNotificationsUseCase
    ) {
        self.fetchNotificationsUseCase = fetchNotificationsUseCase
        self.markAsReadUseCase = markAsReadUseCase
        self.deleteNotificationsUseCase = deleteNotificationsUseCase
        self.deleteAllNotificationsUseCase = deleteAllNotificationsUseCase
    }
    
    // MARK: - Public Methods
    
    /// 알림 목록 로드
    public func loadNotifications() async {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 0
        errorMessage = nil
        
        do {
            let (newNotifications, hasNext) = try await fetchNotificationsUseCase.execute(
                page: currentPage,
                size: pageSize
            )
            notifications = newNotifications
            hasMore = hasNext
        } catch {
            errorMessage = "알림을 불러오는데 실패했습니다."
            #if DEBUG
            print("❌ Failed to load notifications: \(error)")
            #endif
        }
        
        isLoading = false
    }
    
    /// 추가 알림 로드 (페이지네이션)
    public func loadMoreNotifications() async {
        guard !isLoadingMore, hasMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let (newNotifications, hasNext) = try await fetchNotificationsUseCase.execute(
                page: currentPage,
                size: pageSize
            )
            notifications.append(contentsOf: newNotifications)
            hasMore = hasNext
        } catch {
            errorMessage = "알림을 불러오는데 실패했습니다."
            #if DEBUG
            print("❌ Failed to load more notifications: \(error)")
            #endif
        }
        
        isLoadingMore = false
    }
    
    /// 새로고침
    public func refresh() async {
        await loadNotifications()
    }
    
    /// 알림 읽음 처리
    public func markAsRead(_ notification: ModelsShared.Notification) {
        guard !notification.isRead else { return }
        
        // Update local state
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
        
        // Call API to mark as read
        Task {
            do {
                _ = try await markAsReadUseCase.execute(notificationIds: [notification.id])
            } catch {
                #if DEBUG
                print("❌ Failed to mark as read: \(error)")
                #endif
            }
        }
    }
    
    /// 알림 안읽음 처리
    public func markAsUnread(_ notification: ModelsShared.Notification) {
        guard notification.isRead else { return }
        
        // Update local state
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = false
        }
        
        // Call API to mark as unread (현재는 읽음 처리만 API가 있으므로 로컬만 업데이트)
        // TODO: 서버에 안읽음 처리 API가 추가되면 연동 필요
    }
    
    /// 알림 읽음/안읽음 토글
    public func toggleReadStatus(_ notification: ModelsShared.Notification) {
        if notification.isRead {
            markAsUnread(notification)
        } else {
            markAsRead(notification)
        }
    }
    
    /// 알림 삭제
    public func deleteNotification(_ notification: ModelsShared.Notification) {
        // Update local state
        notifications.removeAll { $0.id == notification.id }
        
        // Call API to delete
        Task {
            do {
                _ = try await deleteNotificationsUseCase.execute(notificationIds: [notification.id])
            } catch {
                #if DEBUG
                print("❌ Failed to delete notification: \(error)")
                #endif
            }
        }
    }
    
    /// 전체 알림 삭제
    public func deleteAllNotifications() {
        // Update local state
        notifications.removeAll()
        
        // Call API to delete all
        Task {
            do {
                _ = try await deleteAllNotificationsUseCase.execute()
            } catch {
                #if DEBUG
                print("❌ Failed to delete all notifications: \(error)")
                #endif
            }
        }
    }
    
    /// 알림 설정 Alert 표시
    public func showSettingsConfirmation() {
        showSettingsAlert = true
    }
    
    /// 알림 설정으로 이동
    public func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            Task {
                await UIApplication.shared.open(url)
            }
        }
    }
}

