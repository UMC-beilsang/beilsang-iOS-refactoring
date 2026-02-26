//
//  Notification.swift
//  ModelsShared
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation

public struct Notification: Identifiable, Codable {
    public let id: String
    public let type: NotificationType
    public let title: String
    public let message: String
    public let createdAt: Date
    public var isRead: Bool
    public let relatedId: String?  // 연관된 챌린지 ID 등
    
    public init(
        id: String,
        type: NotificationType,
        title: String,
        message: String,
        createdAt: Date,
        isRead: Bool,
        relatedId: String? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.createdAt = createdAt
        self.isRead = isRead
        self.relatedId = relatedId
    }
}

// MARK: - Preview용 Mock Data
extension Notification {
    public static let mockData: [Notification] = [
        Notification(
            id: "1",
            type: .challengeStart,
            title: "참여 챌린지 시작 알림",
            message: "비일상 님이 참여하는 플로깅 챌린지가 시작했어요!",
            createdAt: Date().addingTimeInterval(-3600),
            isRead: false
        ),
        Notification(
            id: "2",
            type: .challengeReminder,
            title: "챌린지 인증 알림",
            message: "오늘의 챌린지 인증을 잊지 마세요!",
            createdAt: Date().addingTimeInterval(-7200),
            isRead: false
        ),
        Notification(
            id: "3",
            type: .recommendChallenge,
            title: "추천 챌린지 알림",
            message: "비일상 님이 관심 가질 챌린지를 확인해 보세요!!",
            createdAt: Date().addingTimeInterval(-10800),
            isRead: false
        ),
        Notification(
            id: "4",
            type: .newChallenge,
            title: "신규 챌린지 알림",
            message: "다회용기 챌린지가 새로 등록됐어요. 지금 바로 확인해 보세요!",
            createdAt: Date().addingTimeInterval(-14400),
            isRead: false
        )
    ]
}







