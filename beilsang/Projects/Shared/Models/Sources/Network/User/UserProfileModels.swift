//
//  UserProfileModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation

// MARK: - Response
public typealias UserProfileResponse = APIResponse<UserProfileData>

public struct UserProfileData: Codable, Sendable {
    public let resolution: String?
    public let points: Int
    public let nickName: String?
    public let profileImage: String?
    public let address: String?
    public let gender: String?
    public let birth: String?
    public let feedDTOs: [MyPageFeedDTO]
    public let countFeed: Int
    public let challenges: Int
    public let failedChallenges: Int
    public let successChallenge: Int
    public let likes: Int
    
    // Computed properties for backward compatibility
    public var nickname: String { nickName ?? "" }
    public var totalPoint: Int { points }
    public var profileUrl: String? { profileImage }
    public var participatingChallengeCount: Int { challenges }
    public var completedChallengeCount: Int { successChallenge }
    
    enum CodingKeys: String, CodingKey {
        case resolution
        case points
        case nickName
        case profileImage
        case address
        case gender
        case birth
        case feedDTOs
        case countFeed
        case challenges
        case failedChallenges
        case successChallenge
        case likes
    }
    
    public init(
        resolution: String? = nil,
        points: Int,
        nickName: String? = nil,
        profileImage: String? = nil,
        address: String? = nil,
        gender: String? = nil,
        birth: String? = nil,
        feedDTOs: [MyPageFeedDTO] = [],
        countFeed: Int = 0,
        challenges: Int = 0,
        failedChallenges: Int = 0,
        successChallenge: Int = 0,
        likes: Int = 0
    ) {
        self.resolution = resolution
        self.points = points
        self.nickName = nickName
        self.profileImage = profileImage
        self.address = address
        self.gender = gender
        self.birth = birth
        self.feedDTOs = feedDTOs
        self.countFeed = countFeed
        self.challenges = challenges
        self.failedChallenges = failedChallenges
        self.successChallenge = successChallenge
        self.likes = likes
    }
}

public struct MyPageFeedDTO: Codable, Sendable {
    public let feedId: Int
    public let feedUrl: String
    public let day: Int
    
    public init(feedId: Int, feedUrl: String, day: Int) {
        self.feedId = feedId
        self.feedUrl = feedUrl
        self.day = day
    }
}

// MARK: - Profile Update Request
public struct ProfileUpdateRequest: Codable, Sendable {
    public let nickName: String
    public let birth: String
    public let gender: String
    public let address: String
    public let resolution: String
    
    public init(nickName: String, birth: String, gender: String, address: String, resolution: String) {
        self.nickName = nickName
        self.birth = birth
        self.gender = gender
        self.address = address
        self.resolution = resolution
    }
}

// MARK: - Profile Update Response
public typealias ProfileUpdateAPIResponse = APIResponse<ProfileUpdateResponse>

public struct ProfileUpdateResponse: Codable, Sendable {
    public let nickName: String
    public let birth: String
    public let gender: String
    public let address: String
    public let resolution: String
    
    public init(nickName: String, birth: String, gender: String, address: String, resolution: String) {
        self.nickName = nickName
        self.birth = birth
        self.gender = gender
        self.address = address
        self.resolution = resolution
    }
}

// MARK: - Profile Image Update
public struct ProfileImageRequest: Codable, Sendable {
    public let profileImage: String
    
    public init(profileImage: String) {
        self.profileImage = profileImage
    }
}

public typealias ProfileImageResponse = APIResponse<String>

// MARK: - Profile Image Fetch
public struct ProfileImageData: Codable, Sendable {
    public let profileUrl: String?
    
    public init(profileUrl: String?) {
        self.profileUrl = profileUrl
    }
}

// MARK: - Nickname
public struct NicknameData: Codable, Sendable {
    public let nickName: String
    
    public init(nickName: String) {
        self.nickName = nickName
    }
}

public struct NicknameUpdateRequest: Codable, Sendable {
    public let nickName: String
    
    public init(nickName: String) {
        self.nickName = nickName
    }
}

// MARK: - Challenge Count
public struct ChallengeCountData: Codable, Sendable {
    public let challenges: Int
    public let successChallenge: Int
    public let failedChallenges: Int
    
    public init(challenges: Int, successChallenge: Int, failedChallenges: Int) {
        self.challenges = challenges
        self.successChallenge = successChallenge
        self.failedChallenges = failedChallenges
    }
}

// MARK: - Feed Count
public struct FeedCountData: Codable, Sendable {
    public let countFeed: Int
    
    public init(countFeed: Int) {
        self.countFeed = countFeed
    }
}

// MARK: - Like Count
public struct LikeCountData: Codable, Sendable {
    public let likes: Int
    
    public init(likes: Int) {
        self.likes = likes
    }
}

// MARK: - Empty Response (빈 body 처리용)
public struct EmptyResponse: Codable, Sendable {
    public init() {}
    
    // 빈 데이터도 디코딩 가능하도록
    public init(from decoder: Decoder) throws {
        // 빈 응답 허용
    }
}

