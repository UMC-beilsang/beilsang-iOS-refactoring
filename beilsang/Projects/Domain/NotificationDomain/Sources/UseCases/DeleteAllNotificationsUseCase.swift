//
//  DeleteAllNotificationsUseCase.swift
//  NotificationDomain
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation

public final class DeleteAllNotificationsUseCase {
    private let repository: NotificationRepositoryProtocol
    
    public init(repository: NotificationRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> Bool {
        return try await repository.deleteAllNotifications()
    }
}







