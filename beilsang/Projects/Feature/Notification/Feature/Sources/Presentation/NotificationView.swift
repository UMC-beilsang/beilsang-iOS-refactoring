//
//  NotificationView.swift
//  NotificationFeature
//
//  Created by Park Seyoung on 12/18/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared

public struct NotificationView: View {
    @StateObject private var viewModel: NotificationViewModel
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.dismiss) var dismiss
    
    public init(viewModel: NotificationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 헤더
            Header(type: .tertiaryMenu(
                title: "알림",
                onBack: { dismiss() },
                menuTitle: "알림 끄기",
                onMenuAction: {
                    viewModel.deleteAllNotifications()
                }
            ))
            
            // 알림 목록 또는 빈 상태
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                loadingView
            } else if viewModel.notifications.isEmpty {
                emptyStateView
            } else {
                notificationListView
            }
        }
        .background(ColorSystem.backgroundNormalNormal)
        .task {
            await viewModel.loadNotifications()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 100)
            
            Image("noNotiIcon", bundle: .designSystem)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text("새로운 알림이 없어요")
                .fontStyle(.body2Medium)
                .foregroundStyle(ColorSystem.labelNormalBasic)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Notification List View
    private var notificationListView: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                NotificationItemView(
                    notification: notification,
                    onTap: {
                        viewModel.markAsRead(notification)
                    }
                )
                // 오른쪽 스와이프: 삭제
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(
                        "Delete", systemImage: "trash",
                        role: .destructive
                    ) {
                        viewModel.deleteNotification(notification)
                        toastManager.show(
                            iconName: "toastCheckIcon",
                            message: "삭제되었습니다"
                        )
                    }
                    .labelStyle(.iconOnly)
                    .tint(ColorSystem.semanticNegativeHeavy)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(
                    notification.isRead ? ColorSystem.backgroundNormalNormal : ColorSystem.labelNormalDisable
                )
                .onAppear {
                    // 마지막 아이템에 도달하면 더 로드
                    if notification.id == viewModel.notifications.last?.id,
                       viewModel.hasMore {
                        Task {
                            await viewModel.loadMoreNotifications()
                        }
                    }
                }
            }
            
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Notification Item View
struct NotificationItemView: View {
    let notification: ModelsShared.Notification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top) {
                HStack(spacing: 8) {
                    VStack {
                        // 아이콘
                        notificationIcon
                            .frame(width: 20, height: 20)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(width: 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // 제목
                        Text(notification.title)
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.primaryStrong)
                            .multilineTextAlignment(.leading)
                        
                        // 메시지
                        Text(notification.message)
                            .fontStyle(.body2SemiBold)
                            .foregroundStyle(ColorSystem.labelNormalNormal)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                VStack {
                    // 시간
                    Text(notification.createdAt.timeAgoString())
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                    
                    Spacer()
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var notificationIcon: some View {
        ZStack {
            Image(iconName, bundle: .designSystem)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }
    
    private var iconName: String {
        switch notification.type {
        case .challengeStart:
            return "notiBellIcon"
        case .challengeReminder:
            return "notiCertIcon"
        case .newChallenge:
            return "notiNewIcon"
        case .recommendChallenge:
            return "notiRecommendIcon"
        case .weeklyResult:
            return "notiResultIcon"
        case .challengeResult:
            return "notiResultIcon"
        }
    }
}

// MARK: - Date Extension
extension Date {
    func timeAgoString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: now)
        
        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)개월 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금 전"
        }
    }
}

// MARK: - Preview
#Preview("알림 목록") {
    NotificationView(viewModel: NotificationContainer.mock.makeNotificationViewModel())
        .environmentObject(ToastManager())
}

#Preview("빈 알림") {
    let container = NotificationContainer.mock
    let viewModel = container.makeNotificationViewModel()
    viewModel.notifications = []
    return NotificationView(viewModel: viewModel)
        .environmentObject(ToastManager())
}

#Preview("알림 아이템") {
    VStack(spacing: 0) {
        NotificationItemView(
            notification: ModelsShared.Notification.mockData[0],
            onTap: { print("Tapped") }
        )
        NotificationItemView(
            notification: ModelsShared.Notification.mockData[1],
            onTap: { print("Tapped") }
        )
    }
}

