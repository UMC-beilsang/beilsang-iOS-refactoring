
//
//  ChallengeListModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Response
public typealias ChallengeListResponse = APIResponse<ChallengeListData>

public struct ChallengeListData: Codable, Sendable {
    public let content: [ChallengeListItem]
    public let page: Int
    public let size: Int
    public let totalElements: Int
    public let totalPages: Int
    
    public var hasNext: Bool {
        page < totalPages - 1
    }
    
    public init(content: [ChallengeListItem], page: Int, size: Int, totalElements: Int, totalPages: Int) {
        self.content = content
        self.page = page
        self.size = size
        self.totalElements = totalElements
        self.totalPages = totalPages
    }
}

// MARK: - Challenge List Item
public struct ChallengeListItem: Codable, Identifiable, Sendable {
    public let challengeId: Int
    public let title: String
    public let category: String
    public let startDate: String
    public let endDate: String
    public let status: String // NOT_YET, IN_PROGRESS, END
    public let attendeeCount: Int
    public let countLikes: Int
    public let isLiked: Bool
    public let isJoined: Bool
    
    // Backward compatibility
    public var id: Int { challengeId }
    public var participantCount: Int { attendeeCount }
    public var likeCount: Int { countLikes }
    public var thumbnailImageUrl: String? { nil } // 백엔드 추가 전까지 nil
    public var progress: Double { 0.0 } // 백엔드 추가 전까지 0.0
    public var isRecruitmentClosed: Bool {
        status != "NOT_YET"
    }
    
    public init(
        challengeId: Int,
        title: String,
        category: String,
        startDate: String,
        endDate: String,
        status: String,
        attendeeCount: Int,
        countLikes: Int,
        isLiked: Bool,
        isJoined: Bool
    ) {
        self.challengeId = challengeId
        self.title = title
        self.category = category
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.attendeeCount = attendeeCount
        self.countLikes = countLikes
        self.isLiked = isLiked
        self.isJoined = isJoined
    }
}

// 추천, 검색에서 사용
public struct ChallengeItem: Codable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let category: String
    public let status: String?
    public let participantCount: Int
    public let likeCount: Int
    public let imageUrl: String
    public let description: String
    public let progress: Double?
    
    // Backward compatibility
    public var thumbnailImageUrl: String? { imageUrl.isEmpty ? nil : imageUrl }
    public var currentParticipants: Int { participantCount }
    public var isRecruitmentClosed: Bool {
        guard let status = status else { return false }
        return status != "NOT_YET"
    }
}

public struct ChallengePageData: Codable, Sendable {
    public let content: [ChallengeItem]
    public let page: Int
    public let size: Int
    public let totalElements: Int
    public let totalPages: Int
    public var hasNext: Bool { page < totalPages - 1 }
}
