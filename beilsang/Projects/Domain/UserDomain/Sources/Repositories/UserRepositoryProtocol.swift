//
//  UserRepositoryProtocol.swift
//  UserDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import Combine
import ModelsShared

public protocol UserRepositoryProtocol {
    func fetchUserProfile() async throws -> UserProfileData
    func updateProfile(request: ProfileUpdateRequest) async throws -> ProfileUpdateResponse

    // MARK: - 닉네임
    func fetchNickname() async throws -> String
    func updateNickname(_ nickName: String) async throws -> String
    func checkNickname(_ nickname: String) async throws -> Bool

    // MARK: - 프로필 이미지
    func fetchProfileImage() async throws -> String?
    func updateProfileImage(imageData: Data) async throws -> String

    // MARK: - 개수 조회
    func fetchChallengeCount() async throws -> ChallengeCountData
    func fetchFeedCount() async throws -> Int
    func fetchLikeCount() async throws -> Int

    // MARK: - 피드 / 포인트
    func fetchMyFeeds(page: Int, size: Int) async throws -> FeedListResponse
    func fetchPoints() async throws -> PointData
}

