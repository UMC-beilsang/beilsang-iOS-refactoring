//
//  ChallengeQueryRepoImpl.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import Combine
import ModelsShared
import NetworkCore
import UtilityShared
import Alamofire

// MARK: - Empty Request
private struct EmptyRequest: Codable, Sendable {}

public final class ChallengeQueryRepository: ChallengeQueryRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Challenge List 조회
    // Challenge Detail
    public func fetchChallengeDetail(challengeId: Int) async throws -> ChallengeDetailData {
        let path = "challenge/\(challengeId)"
        
        let response: ChallengeDetailResponse = try await apiClient.request(
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
    
    // fetchLikedChallenges
    public func fetchLikedChallenges(request: LikedChallengeListRequest) async throws -> ChallengePageData {
        var queryItems: [String] = []
        if let category = request.category {
            queryItems.append("category=\(category)")
        }
        if let sortType = request.sortType {
            queryItems.append("sortType=\(sortType)")
        }
        queryItems.append("page=\(request.page)")
        queryItems.append("size=\(request.size)")
        
        let path = "challenge/liked?\(queryItems.joined(separator: "&"))"
        
        let response: APIResponse<ChallengePageData> = try await apiClient.request(
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
    
    // fetchClosedChallenges
    public func fetchClosedChallenges(request: ClosedChallengeListRequest) async throws -> ChallengePageData {
        var queryItems: [String] = []
        if let category = request.category {
            queryItems.append("category=\(category)")
        }
        queryItems.append("page=\(request.page)")
        queryItems.append("size=\(request.size)")
        
        let path = "challenge/list/closed?\(queryItems.joined(separator: "&"))"
        
        
        let response: APIResponse<ChallengePageData> = try await apiClient.request(
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
    
    // fetchOpenChallenges
    public func fetchOpenChallenges(request: OpenChallengeListRequest) async throws -> ChallengePageData {
        var queryItems: [String] = []
        if let category = request.category {
            queryItems.append("category=\(category)")
        }
        if let sortType = request.sortType {
            queryItems.append("sortType=\(sortType)")
        }
        queryItems.append("page=\(request.page)")
        queryItems.append("size=\(request.size)")
        
        let path = "challenge/list/open?\(queryItems.joined(separator: "&"))"
        
        let response: APIResponse<ChallengePageData> = try await apiClient.request(
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
    
    // fetchMyChallegnes
    public func fetchMyChallenges(request: MyChallengeListRequest) async throws -> ChallengePageData {
        var queryItems: [String] = []
        if let category = request.category {
            queryItems.append("category=\(category)")
        }
        if let participationStatus = request.participationStatus {
            queryItems.append("participationStatus=\(participationStatus)")
        }
        queryItems.append("page=\(request.page)")
        queryItems.append("size=\(request.size)")
        
        let path = "challenge/my?\(queryItems.joined(separator: "&"))"
        
        let response: APIResponse<ChallengePageData> = try await apiClient.request(
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
    
    // fetchRecommended
    public func fetchRecommended(request: RecommendedChallengeRequest) async throws -> [ChallengeItem] {
        let path = "challenge/recommended?size=\(request.size)"
        
        let response: APIResponse<[ChallengeItem]> = try await apiClient.request(
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
    
    // MARK: - Search
    public func searchClosedChallenges(request: SearchClosedChallengeRequest) async throws -> ChallengePageData {
        let response: APIResponse<ChallengePageData> = try await apiClient.request(
            path: "challenge/search/closed",
            method: .get,
            body: request,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess, let data = response.data else {
            throw ChallengeError.serverError(response.message)
        }
        return data
    }
    
    public func searchOpenChallenges(request: SearchOpenChallengeRequest) async throws -> ChallengePageData {
        let response: APIResponse<ChallengePageData> = try await apiClient.request(
            path: "challenge/search/open",
            method: .get,
            body: request,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess, let data = response.data else {
            throw ChallengeError.serverError(response.message)
        }
        return data
    }
    
    // MARK: - Challenge Enrollment Check
    public func checkChallengeEnrollment(challengeId: Int) async throws -> ChallengeEnrollmentData {
        let path = "api/check/\(challengeId)"
        
        let response: APIResponse<ChallengeEnrollmentData> = try await apiClient.request(
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
    
    // MARK: - Feed Thumbnails (TODO: API 미구현)
    public func fetchChallengeFeedThumbnails(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse {
        // TODO: 백엔드 API 추가 필요
        // GET /feed?challengeId={id}&page={page}
        // 또는 GET /challenge/{id} 응답에 feeds 포함
        
        return ChallengeFeedThumbnailResponse(feeds: [], hasNext: false)
    }
}
