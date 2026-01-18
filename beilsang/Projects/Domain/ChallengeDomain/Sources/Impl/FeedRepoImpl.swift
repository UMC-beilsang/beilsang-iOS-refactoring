//
//  FeedRepoImpl.swift
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

public final class FeedRepoImpl: FeedRepositoryProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Feed List
    public func fetchFeedList(category: String?, page: Int, size: Int) async throws -> FeedListResponse {
        if MockConfig.useMockData {
            #if DEBUG
            print("📷 Using mock feed list")
            #endif
            return FeedListResponse(
                content: [],
                number: page,
                size: size,
                numberOfElements: 0,
                hasNext: false
            )
        }
        
        var path = "feed?page=\(page)&size=\(size)"
        if let category = category {
            path += "&category=\(category)"
        }
        
        #if DEBUG
        print("📷 Fetching feed list: \(path)")
        #endif
        
        let publisher: AnyPublisher<APIResponse<FeedListResponse>, APIClientError> = apiClient.request(
            path: path,
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            #if DEBUG
                            print("📷 Feed list error: \(error)")
                            #endif
                            continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { apiResponse in
                        guard apiResponse.statusCode == 200, let response = apiResponse.data else {
                            continuation.resume(throwing: ChallengeError.serverError(apiResponse.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("📷 Feed list loaded - count: \(response.content.count)")
                        #endif
                        continuation.resume(returning: response)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Create Feed
    public func createFeed(request: FeedCreateRequest) async throws -> FeedCreateData {
        if MockConfig.useMockData {
            #if DEBUG
            print("📝 Using mock feed creation - challengeId: \(request.challengeId)")
            #endif
            return FeedCreateData(
                feedId: Int.random(in: 100...999),
                challengeTitle: "Mock Challenge",
                review: request.review,
                feedUrl: "challengeThumbnail1",
                uploadDate: ISO8601DateFormatter().string(from: Date()),
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
        }
        
        let path = "feed"
        
        #if DEBUG
        print("📝 Creating feed for challenge: \(request.challengeId)")
        #endif
        
        let parameters = [
            "challengeId": "\(request.challengeId)",
            "review": request.review
        ]
        
        let publisher: AnyPublisher<FeedCreateResponse, APIClientError> = apiClient.uploadMultipart(
            path: path,
            parameters: parameters,
            imageData: request.feedImage,
            imageKey: "feedImage",
            imageName: "feed_\(Date().timeIntervalSince1970).jpg",
            mimeType: "image/jpeg",
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            #if DEBUG
                            print("📝 Feed create error: \(error)")
                            #endif
                            continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard response.isSuccess, let data = response.data else {
                            continuation.resume(throwing: ChallengeError.serverError(response.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("📝 Feed created successfully - feedId: \(data.feedId)")
                        #endif
                        continuation.resume(returning: data)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Feed Detail
    public func fetchFeedDetailData(feedId: Int) async throws -> FeedDetailData {
        if MockConfig.useMockData {
            #if DEBUG
            print("📄 Using mock feed detail - feedId: \(feedId)")
            #endif
            return FeedDetailData(
                feedId: feedId,
                memberInfo: MemberInfo(
                    memberId: 1,
                    nickName: "비밀상님",
                    profileImage: ""
                ),
                challengeId: 1,
                challengeTitle: "플로깅",
                challengeCategory: "plogging",
                review: "오늘도 환경을 지키며 운동했습니다!",
                feedUrl: feedId % 2 == 0 ? "challengeThumbnail2" : "challengeThumbnail1",
                uploadDate: ISO8601DateFormatter().string(from: Date()),
                likeCount: 15 + feedId,
                isLiked: feedId % 3 == 0,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
        }
        
        let path = "feed/\(feedId)"
        
        #if DEBUG
        print("📄 Fetching feed detail - feedId: \(feedId)")
        #endif
        
        let publisher: AnyPublisher<FeedDetailResponse, APIClientError> = apiClient.request(
            path: path,
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            #if DEBUG
                            print("📄 Feed detail error: \(error)")
                            #endif
                            continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard response.isSuccess, let data = response.data else {
                            continuation.resume(throwing: ChallengeError.serverError(response.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("📄 Feed detail loaded - feedId: \(data.feedId)")
                        #endif
                        continuation.resume(returning: data)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Challenge Feed Detail (변환)
    public func fetchChallengeFeedDetail(feedId: Int) async throws -> ChallengeFeedDetail {
        let data = try await fetchFeedDetailData(feedId: feedId)
        
        // FeedDetailData를 ChallengeFeedDetail로 변환
        return ChallengeFeedDetail(
            id: data.feedId,
            feedUrl: data.feedUrl,
            day: 0,
            userName: data.memberInfo.nickName,
            userProfileImageUrl: data.memberInfo.profileImage,
            description: data.review,
            likeCount: data.likeCount,
            isLiked: data.isLiked,
            challengeTags: [data.challengeCategory],
            createdAt: ChallengeRepositoryHelpers.parseDate(data.createdAt) ?? Date(),
            isMyFeed: false
        )
    }
    
    // MARK: - Toggle Feed Like
    public func toggleFeedLike(feedId: Int, currentlyLiked: Bool) async throws -> FeedLikeData {
        if MockConfig.useMockData {
            #if DEBUG
            print("❤️ Using mock feed like toggle - feedId: \(feedId), currentlyLiked: \(currentlyLiked)")
            #endif
            return FeedLikeData(
                feedId: feedId,
                likeCount: currentlyLiked ? 14 : 15,
                isLiked: !currentlyLiked
            )
        }
        
        let path = "feed/\(feedId)/like"
        
        #if DEBUG
        print("❤️ Toggling feed like - feedId: \(feedId), currentlyLiked: \(currentlyLiked)")
        #endif
        
        if currentlyLiked {
            return try await removeFeedLike(feedId: feedId, path: path)
        } else {
            return try await addFeedLike(feedId: feedId, path: path)
        }
    }
    
    // MARK: - Private Helpers
    private func addFeedLike(feedId: Int, path: String) async throws -> FeedLikeData {
        struct EmptyRequest: Encodable, Sendable {}
        
        let publisher: AnyPublisher<FeedLikeResponse, APIClientError> = apiClient.request(
            path: path,
            method: .post,
            body: EmptyRequest(),
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            #if DEBUG
                            print("❤️ Feed like POST error: \(error)")
                            #endif
                            continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard response.isSuccess, let data = response.data else {
                            continuation.resume(throwing: ChallengeError.serverError(response.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("❤️ Feed like added - feedId: \(data.feedId), isLiked: \(data.isLiked)")
                        #endif
                        continuation.resume(returning: data)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    private func removeFeedLike(feedId: Int, path: String) async throws -> FeedLikeData {
        let publisher: AnyPublisher<FeedLikeResponse, APIClientError> = apiClient.request(
            path: path,
            method: .delete,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            #if DEBUG
                            print("❤️ Feed like DELETE error: \(error)")
                            #endif
                            continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard response.isSuccess, let data = response.data else {
                            continuation.resume(throwing: ChallengeError.serverError(response.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("❤️ Feed like removed - feedId: \(data.feedId), isLiked: \(data.isLiked)")
                        #endif
                        continuation.resume(returning: data)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

