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
    func updateProfileImage(imageBase64: String) async throws -> String
    func fetchMyFeeds(page: Int, size: Int) async throws -> FeedListResponse
    func fetchPoints() async throws -> PointData
}

