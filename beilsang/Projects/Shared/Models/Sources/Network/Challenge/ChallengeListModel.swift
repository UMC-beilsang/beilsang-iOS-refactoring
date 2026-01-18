
//
//  ChallengeListModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Request
public struct ChallengeListRequest: Codable, Sendable {
    public let page: Int
    public let size: Int
    public let sortField: SortField?
    public let sortDirection: SortDirection?
    public let category: String?
    public let challengeMemberStatus: ChallengeMemberStatus?
    public let challengeStatus: ChallengeStatus?
    public let keyword: String?
    public let isFinished: Bool?
    public let isJoined: Bool?
    public let memberId: Int?
    
    public enum SortField: String, Codable {
        case attendeeCount = "ATTENDEE_COUNT"
        case likeCount = "LIKE_COUNT"
        case createdDate = "CREATED_DATE"
    }
    
    public enum SortDirection: String, Codable {
        case asc = "ASC"
        case desc = "DESC"
    }
    
    public init(
        page: Int = 0,
        size: Int = 20,
        sortField: SortField? = nil,
        sortDirection: SortDirection? = nil,
        category: String? = nil,
        challengeMemberStatus: ChallengeMemberStatus? = nil,
        challengeStatus: ChallengeStatus? = nil,
        keyword: String? = nil,
        isFinished: Bool? = nil,
        isJoined: Bool? = nil,
        memberId: Int? = nil
    ) {
        self.page = page
        self.size = size
        self.sortField = sortField
        self.sortDirection = sortDirection
        self.category = category
        self.challengeMemberStatus = challengeMemberStatus
        self.challengeStatus = challengeStatus
        self.keyword = keyword
        self.isFinished = isFinished
        self.isJoined = isJoined
        self.memberId = memberId
    }
}

// MARK: - Response
public typealias ChallengeListResponse = APIResponse<ChallengeListData>

public struct ChallengeListData: Codable, Sendable {
    public let content: [ChallengeListItem]
    public let page: Int
    public let size: Int
    public let totalElements: Int
    public let totalPages: Int
    public let hasNext: Bool
}

public struct ChallengeListItem: Codable, Sendable {
    public let id: Int
    public let title: String
    public let category: String
    public let status: ChallengeMemberStatus?
    public let participantCount: Int
    public let likeCount: Int
    public let imageUrl: String
    public let description: String
    public let isRecruitmentClosed: Bool  
}

