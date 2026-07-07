//
//  ChallengeListRequestModels.swift
//  ModelsShared
//
//  Created by Cursor on 2/28/26.
//

import Foundation

public struct OpenChallengeListRequest: Codable, Sendable {
    public let category: String?
    public let sortType: String? // DEADLINE_SOON, NEWEST
    public let page: Int
    public let size: Int
    
    public init(category: String? = nil, sortType: String? = "DEADLINE_SOON", page: Int = 0, size: Int = 10) {
        self.category = category
        self.sortType = sortType
        self.page = page
        self.size = size
    }
}

public struct ClosedChallengeListRequest: Codable, Sendable {
    public let category: String?
    public let page: Int
    public let size: Int
    
    public init(category: String? = nil, page: Int = 0, size: Int = 10) {
        self.category = category
        self.page = page
        self.size = size
    }
}

public struct LikedChallengeListRequest: Codable, Sendable {
    public let category: String?
    public let sortType: String? // DEADLINE_SOON, NEWEST
    public let page: Int
    public let size: Int
    
    public init(category: String? = nil, sortType: String? = "DEADLINE_SOON", page: Int = 0, size: Int = 10) {
        self.category = category
        self.sortType = sortType
        self.page = page
        self.size = size
    }
}

public struct MyChallengeListRequest: Codable, Sendable {
    public let category: String?
    public let participationStatus: String? // ONGOING, SUCCESS, FAIL
    public let page: Int
    public let size: Int
    
    public init(category: String? = nil, participationStatus: String? = "ONGOING", page: Int = 0, size: Int = 10) {
        self.category = category
        self.participationStatus = participationStatus
        self.page = page
        self.size = size
    }
}

public struct RecommendedChallengeRequest: Codable, Sendable {
    public let size: Int
    
    // 기본 사이즈 2
    public init(size: Int = 2) {
        self.size = size
    }
}

public struct SearchClosedChallengeRequest: Codable, Sendable {
    public let keyword: String
    public let page: Int
    public let size: Int
    
    public init(keyword: String, page: Int = 0, size: Int = 10) {
        self.keyword = keyword
        self.page = page
        self.size = size
    }
}

public struct SearchOpenChallengeRequest: Codable, Sendable {
    public let keyword: String
    public let sortType: String? // DEADLINE_SOON, NEWEST
    public let page: Int
    public let size: Int
    
    public init(keyword: String, sortType: String? = "DEADLINE_SOON", page: Int = 0, size: Int = 10) {
        self.keyword = keyword
        self.sortType = sortType
        self.page = page
        self.size = size
    }
}
