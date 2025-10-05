//
//  ChallengeFeedDetail.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/16/25.
//

import Foundation

public struct ChallengeFeedDetail: Identifiable {
    public let id: Int
    public let feedUrl: String
    public let day: Int
    public let userName: String
    public let userProfileImageUrl: String?
    public let description: String
    public let likeCount: Int
    public let isLiked: Bool
    public let challengeTags: [String]
    public let createdAt: Date
    public let isMyFeed: Bool
    
    public init(
        id: Int,
        feedUrl: String,
        day: Int,
        userName: String,
        userProfileImageUrl: String?,
        description: String,
        likeCount: Int,
        isLiked: Bool,
        challengeTags: [String],
        createdAt: Date,
        isMyFeed: Bool
    ) {
        self.id = id
        self.feedUrl = feedUrl
        self.day = day
        self.userName = userName
        self.userProfileImageUrl = userProfileImageUrl
        self.description = description
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.challengeTags = challengeTags
        self.createdAt = createdAt
        self.isMyFeed = isMyFeed
    }
}

//extension ChallengeFeedDetail {
//    public init(from response: ChallengeFeedDetailResponse) {
//        self.init(
//            id: response.feedId,
//            feedUrl: response.feedUrl,
//            day: response.day,
//            userName: response.userName,
//            userProfileImageUrl: response.userProfileImageUrl,
//            description: response.description,
//            likeCount: response.likeCount,
//            isLiked: response.isLiked,
//            challengeTags: response.challengeTags,
//            createdAt: response.createdAt
//        )
//    }
//}
