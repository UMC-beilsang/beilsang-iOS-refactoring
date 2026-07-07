//
//  FeedRepository.swift
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

private struct EmptyRequest: Codable, Sendable {}

private struct SearchFeedParams: Encodable {
    let keyword: String
    let sortType: String
    let category: String?
    let page: Int
    let size: Int
}

public final class FeedRepository: FeedRepositoryProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // 카테고리별 피드 리스트 불러오기
    public func fetchFeedList(category: String?, page: Int, size: Int) async throws -> FeedListResponse {
        var path = "feed?page=\(page)&size=\(size)"
        if let category = category {
            path += "&category=\(category)"
        }
        
        let response: APIResponse<FeedListResponse> = try await apiClient.request(
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
    
    // 피드 생성하기
    public func createFeed(request: FeedCreateRequest, feedImage: Data?) async throws -> FeedCreateData {
        let path = "feed"

        let response: FeedCreateResponse = try await apiClient.upload(
            path: path,
            method: .post,
            formData: { formData in
                if let jsonData = try? JSONEncoder().encode(request) {
                    formData.append(jsonData, withName: "data", mimeType: "application/json")
                }
                if let imageData = feedImage {
                    formData.append(
                        imageData,
                        withName: "feedImage",
                        fileName: "feed_\(Date().timeIntervalSince1970).jpg",
                        mimeType: "image/jpeg"
                    )
                }
            },
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess, let data = response.data else {
            throw ChallengeError.serverError(response.message)
        }
        return data
    }
    
    // Feed Detail
    public func fetchFeedDetailData(feedId: Int) async throws -> FeedDetailData {
        let path = "feed/\(feedId)"
        
        // 1. 전체 상자(FeedDetailResponse) 타입으로 요청합니다.
        let response: FeedDetailResponse = try await apiClient.request(
            path: path,
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        // 2. 상자가 성공인지 확인하고, 그 안의 'data' 알맹이만 꺼냅니다.
        guard response.isSuccess, let data = response.data else {
            // 실패 시 서버 메시지를 담아 에러를 던집니다.
            throw NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }
        
        return data
    }
    
    // 좋아요, 삭제
    public func toggleFeedLike(feedId: Int, currentlyLiked: Bool) async throws -> FeedLikeData {
        let path = "feed/\(feedId)/like"
        
        if currentlyLiked {
            return try await apiClient.request(
                path: path,
                method: .delete,
                headers: APIClient.defaultHeaders,
                interceptor: nil
            )
        } else {
            return try await apiClient.request(
                path: path,
                method: .post,
                body: EmptyRequest(),
                encoder: JSONParameterEncoder.default,
                headers: APIClient.jsonHeaders,
                interceptor: nil
            )
        }
    }
   
    // 참여자 피드 조회
    public func fetchMemberFeeds(memberId: Int, page: Int, size: Int) async throws -> FeedListResponse {
        let path = "feed/member/\(memberId)?page=\(page)&size=\(size)"

        let response: APIResponse<FeedListResponse> = try await apiClient.request(
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

    // 내 피드 조회
    public func fetchMyFeeds(category: String?, page: Int, size: Int) async throws -> FeedListResponse {
        var path = "feed/my?page=\(page)&size=\(size)"
        if let category = category {
            path += "&category=\(category)"
        }
        
        let response: APIResponse<FeedListResponse> = try await apiClient.request(
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
    
    // 피드 신고
    public func reportFeed(feedId: Int, reason: String, detail: String? = nil) async throws {
        let path = "feed/\(feedId)/report"

        do {
            let response: APIResponse<String> = try await apiClient.request(
                path: path,
                method: .post,
                body: FeedReportRequest(reason: reason, detail: detail),
                encoder: JSONParameterEncoder.default,
                headers: APIClient.jsonHeaders,
                interceptor: nil
            )
            guard response.isSuccess else {
                throw ChallengeError.serverError(response.message)
            }
        } catch APIClientError.http(_, let data) {
            let message = data
                .flatMap { try? JSONDecoder().decode(APIResponse<String>.self, from: $0) }
                .map(\.message)
                ?? "신고 처리 중 오류가 발생했습니다"
            throw ChallengeError.serverError(message)
        }
    }

    // 피드 검색
    public func searchFeeds(keyword: String, sortType: String = "NEWEST", category: String?, page: Int, size: Int) async throws -> SearchFeedPageData {
        let params = SearchFeedParams(
            keyword: keyword,
            sortType: sortType,
            category: category,
            page: page,
            size: size
        )
        
        let response: APIResponse<SearchFeedPageData> = try await apiClient.request(
            path: "feed/search",
            method: .get,
            body: params,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess, let data = response.data else {
            throw ChallengeError.serverError(response.message)
        }
        return data
    }
}

