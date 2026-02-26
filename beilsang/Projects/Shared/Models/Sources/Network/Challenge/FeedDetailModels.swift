//
//  FeedDetailModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Response
public typealias FeedDetailResponse = APIResponse<FeedDetailData>

public struct FeedDetailData: Decodable, Sendable {
    public let feedId: Int
    public let memberInfo: MemberInfo
    public let challengeId: Int
    public let challengeTitle: String
    public let challengeCategory: String
    public let review: String
    public let feedUrl: String
    public let uploadDate: String
    public let likeCount: Int
    public let isLiked: Bool
    public let createdAt: String
    public let updatedAt: String
    
    public init(
        feedId: Int,
        memberInfo: MemberInfo,
        challengeId: Int,
        challengeTitle: String,
        challengeCategory: String,
        review: String,
        feedUrl: String,
        uploadDate: String,
        likeCount: Int,
        isLiked: Bool,
        createdAt: String,
        updatedAt: String
    ) {
        self.feedId = feedId
        self.memberInfo = memberInfo
        self.challengeId = challengeId
        self.challengeTitle = challengeTitle
        self.challengeCategory = challengeCategory
        self.review = review
        self.feedUrl = feedUrl
        self.uploadDate = uploadDate
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct MemberInfo: Decodable, Sendable {
    public let memberId: Int
    public let nickName: String
    public let profileImage: String
    
    public init(memberId: Int, nickName: String, profileImage: String) {
        self.memberId = memberId
        self.nickName = nickName
        self.profileImage = profileImage
    }
}

