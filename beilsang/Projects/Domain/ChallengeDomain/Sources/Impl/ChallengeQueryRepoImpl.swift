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

// MARK: - Empty Request
private struct EmptyRequest: Codable, Sendable {}

public final class ChallengeQueryRepoImpl: ChallengeQueryRepositoryProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Active Challenges
    public func fetchActiveChallenges() async throws -> [Challenge] {
        let request = ChallengeListRequest(
            page: 0,
            size: 20,
            challengeStatus: .inProgress,
            isJoined: true
        )
        return try await fetchChallengeList(request: request)
    }
    
    // MARK: - Recommended Challenges
    public func fetchRecommendedChallenges() async throws -> [Challenge] {
        let request = ChallengeListRequest(
            page: 0,
            size: 10,
            category: nil,
            challengeStatus: nil,
            isJoined: nil
        )
        return try await fetchChallengeList(request: request)
    }
    
    // MARK: - Challenge List
    public func fetchChallengeList(request: ChallengeListRequest) async throws -> [Challenge] {
        if MockConfig.useMockData {
            #if DEBUG
            print("🎯 Using mock challenge list")
            #endif
            // Mock 데이터는 MockChallengeData 사용
            return Array(MockChallengeData.challenges.prefix(10))
        }
        
        // Query parameters를 직접 path에 추가
        var queryItems: [String] = []
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        
        if let jsonData = try? encoder.encode(request),
           let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            for (key, value) in dict {
                if let stringValue = value as? String {
                    queryItems.append("\(key)=\(stringValue)")
                } else if let intValue = value as? Int {
                    queryItems.append("\(key)=\(intValue)")
                } else if let boolValue = value as? Bool {
                    queryItems.append("\(key)=\(boolValue)")
                }
            }
        }
        
        let path = "challenge?\(queryItems.joined(separator: "&"))"
        
        #if DEBUG
        print("🎯 Fetching challenge list: \(path)")
        #endif
        
        let publisher: AnyPublisher<ChallengeListResponse, APIClientError> = apiClient.request(
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
                            print("🎯 Challenge list error: \(error)")
                            #endif
                            if case .decoding = error {
                                continuation.resume(returning: [])
                            } else {
                                continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                            }
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        do {
                            guard response.isSuccess else {
                                throw ChallengeError.serverError(response.message)
                            }
                            
                            guard let data = response.data else {
                                continuation.resume(returning: [])
                                cancellable?.cancel()
                                return
                            }
                            
                            let challenges = data.content.map { item in
                                ChallengeRepositoryHelpers.mapToChallenge(from: item)
                            }
                            continuation.resume(returning: challenges)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Challenge Detail
    public func fetchChallengeDetail(challengeId: Int) async throws -> Challenge {
        if MockConfig.useMockData {
            #if DEBUG
            print("🎯 Using mock challenge detail - ID: \(challengeId)")
            #endif
            return MockChallengeData.challenges.first ?? MockChallengeData.challenges[0]
        }
        
        let path = "challenge/\(challengeId)"
        
        #if DEBUG
        print("🎯 Fetching challenge detail - ID: \(challengeId)")
        #endif
        
        let publisher: AnyPublisher<ChallengeDetailResponse, APIClientError> = apiClient.request(
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
                            print("🎯 Challenge detail error: \(error)")
                            #endif
                            continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        do {
                            guard response.isSuccess else {
                                throw ChallengeError.serverError(response.message)
                            }
                            
                            guard let data = response.data else {
                                throw ChallengeError.serverError("챌린지 데이터가 없습니다.")
                            }
                            
                            let challenge = ChallengeRepositoryHelpers.mapToChallenge(from: data)
                            continuation.resume(returning: challenge)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Feed Thumbnails
    public func fetchChallengeFeedThumbnails(challengeId: Int, page: Int?) async throws -> ChallengeFeedThumbnailResponse {
        if MockConfig.useMockData {
            #if DEBUG
            print("📷 Using mock challenge feed thumbnails - challengeId: \(challengeId)")
            #endif
            let mockThumbnails: [ChallengeFeedThumbnail] = (1...8).map {
                ChallengeFeedThumbnail(
                    feedId: $0,
                    feedUrl: $0 % 2 == 0 ? "challengeThumbnail2" : "challengeThumbnail1",
                    day: $0,
                    isMyFeed: $0 % 3 == 0
                )
            }
            return ChallengeFeedThumbnailResponse(feeds: mockThumbnails, hasNext: (page ?? 0) < 2)
        }
        
        let mockThumbnails: [ChallengeFeedThumbnail] = (1...8).map {
            ChallengeFeedThumbnail(
                feedId: $0,
                feedUrl: $0 % 2 == 0 ? "challengeThumbnail2" : "challengeThumbnail1",
                day: $0,
                isMyFeed: $0 % 3 == 0
            )
        }
        return ChallengeFeedThumbnailResponse(feeds: mockThumbnails, hasNext: (page ?? 0) < 2)
    }
    
    // MARK: - Hall of Fame
    public func fetchHonorsChallenges(by keyword: Keyword) async throws -> [Challenge] {
        if MockConfig.useMockData {
            #if DEBUG
            print("🏆 Using mock hall of fame - category: \(keyword.apiCategory)")
            #endif
            return Array(MockChallengeData.challenges.prefix(5))
        }
        
        let category = keyword.apiCategory
        let path = "api/achievement/hall-of-fame/\(category)"
        
        #if DEBUG
        print("🏆 Fetching hall of fame - category: \(category)")
        #endif
        
        let publisher: AnyPublisher<HallOfFameResponse, APIClientError> = apiClient.request(
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
                            print("🏆 Hall of fame error: \(error)")
                            #endif
                            if case .decoding = error {
                                continuation.resume(returning: [])
                            } else {
                                continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                            }
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        do {
                            guard response.isSuccess else {
                                throw ChallengeError.serverError(response.message)
                            }
                            
                            guard let data = response.data else {
                                continuation.resume(returning: [])
                                cancellable?.cancel()
                                return
                            }
                            
                            let challenges = data.challenges.map { item in
                                ChallengeRepositoryHelpers.mapToChallenge(from: item)
                            }
                            continuation.resume(returning: challenges)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Keyword Feeds
    public func fetchKeywordFeeds(by keyword: Keyword, page: Int) async throws -> [ChallengeFeedDetail] {
        if MockConfig.useMockData {
            #if DEBUG
            print("🔍 Using mock keyword feeds - keyword: \(keyword.title)")
            #endif
            return []
        }
        
        let category = keyword.apiCategory
        let path = "feed?category=\(category)&page=\(page)&size=10"
        
        #if DEBUG
        print("🔍 Fetching keyword feeds - keyword: \(keyword.title), page: \(page)")
        #endif
        
        let publisher: AnyPublisher<FeedsByCategoryResponse, APIClientError> = apiClient.request(
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
                            print("🔍 Keyword feeds error: \(error)")
                            #endif
                            if case .decoding = error {
                                continuation.resume(returning: [])
                            } else {
                                continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                            }
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        do {
                            guard response.isSuccess else {
                                throw ChallengeError.serverError(response.message)
                            }
                            
                            guard let data = response.data else {
                                continuation.resume(returning: [])
                                cancellable?.cancel()
                                return
                            }
                            
                            let feeds = data.content.map { item in
                                ChallengeRepositoryHelpers.mapToFeedDetail(from: item, keyword: keyword)
                            }
                            continuation.resume(returning: feeds)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Challenge Enrollment Check
    public func checkChallengeEnrollment(challengeId: Int) async throws -> ChallengeEnrollmentData {
        if MockConfig.useMockData {
            #if DEBUG
            print("✅ Using mock challenge enrollment check")
            #endif
            return ChallengeEnrollmentData(isEnrolled: false, enrolledChallengeIds: [])
        }
        
        let path = "challenge/\(challengeId)/enrollment"
        
        #if DEBUG
        print("✅ Checking challenge enrollment - ID: \(challengeId)")
        #endif
        
        let publisher: AnyPublisher<ChallengeEnrollmentResponse, APIClientError> = apiClient.request(
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
                            print("✅ Challenge enrollment check error: \(error)")
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
                        print("✅ Challenge enrollment status: \(data.isEnrolled)")
                        #endif
                        continuation.resume(returning: data)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

