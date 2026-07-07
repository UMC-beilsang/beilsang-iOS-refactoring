//
//  DiscoverRepoImpl.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 3/10/26.
//

import Foundation
import ModelsShared
import NetworkCore
import UtilityShared

public final class DiscoverRepository: DiscoverRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    public func fetchKeywordFeeds(by keyword: Keyword, page: Int, size: Int) async throws -> DiscoverFeedPageData {
        let path = "api/achievement/feeds/\(keyword.apiCategory)?page=\(page)&size=\(size)"
        
        let response: APIResponse<DiscoverFeedPageData> = try await apiClient.request(
            path: path,
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess, let data = response.data else {
            throw ChallengeError.serverError(response.message)
        }
        return data
    }
    
    public func fetchHonorsChallenges(by keyword: Keyword) async throws -> HallOfFameData {
        let path = "api/achievement/hall-of-fame/\(keyword.apiCategory)"
        
        let response: APIResponse<HallOfFameData> = try await apiClient.request(
            path: path,
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess, let data = response.data else {
            throw ChallengeError.serverError(response.message)
        }
        return data
    }
}
