//
//  NotificationCoordinator.swift
//  NotificationFeature
//
//  Created by Park Seyoung on 12/18/25.
//

import SwiftUI
import NavigationShared

public enum NotificationRoute: Hashable {
    case notificationDetail(id: String)
}

@MainActor
public final class NotificationCoordinator: ObservableObject {
    @Published public var path = NavigationPath()
    
    // Dependencies
    public let container: NotificationContainer
    
    public init(container: NotificationContainer) {
        self.container = container
    }
    
    // MARK: - Navigation
    public func navigateToDetail(id: String) {
        path.append(NotificationRoute.notificationDetail(id: id))
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    // MARK: - Navigation Destination Factory
    @ViewBuilder
    public func makeDestinationView(for route: NotificationRoute) -> some View {
        switch route {
        case .notificationDetail(let id):
            // TODO: 알림 상세 화면 (필요 시 구현)
            Text("알림 상세: \(id)")
        }
    }
}







