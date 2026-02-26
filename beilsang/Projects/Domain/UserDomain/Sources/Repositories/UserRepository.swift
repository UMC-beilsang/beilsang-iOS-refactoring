//
//  UserRepository.swift
//  UserDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import Combine
import ModelsShared
import NetworkCore
import UtilityShared
import Alamofire

public final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    public init(baseURL: String) {
        self.apiClient = APIClient(baseURL: baseURL)
    }
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Mock 데이터
    private let mockUserProfile = UserProfileData(
        resolution: "환경보호에 앞장서는 나",
        points: 916,
        nickName: "비밀상님",
        profileImage: nil,
        address: "서울시 마포구",
        gender: "MAN",
        birth: "2000-01-01",
        feedDTOs: [
            MyPageFeedDTO(feedId: 1, feedUrl: "challengeThumbnail1", day: 1),
            MyPageFeedDTO(feedId: 2, feedUrl: "challengeThumbnail2", day: 2)
        ],
        countFeed: 20,
        challenges: 6,
        failedChallenges: 2,
        successChallenge: 12,
        likes: 24
    )
    
    // MARK: - 사용자 프로필 조회
    public func fetchUserProfile() async throws -> UserProfileData {
        // Mock 데이터 사용 시
        if MockConfig.useMockData {
            #if DEBUG
            print("👤 Using mock user profile")
            #endif
            return mockUserProfile
        }
        
        // 실제 API 호출
        let path = "api/mypage"
        
        #if DEBUG
        print("👤 Fetching user profile from API: GET /\(path)")
        #endif
        
        let publisher: AnyPublisher<UserProfileResponse, APIClientError> = apiClient.request(
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
                            print("👤 User profile error: \(error)")
                            #endif
                            continuation.resume(throwing: UserRepository.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard response.isSuccess, let data = response.data else {
                            #if DEBUG
                            print("👤 User profile failed: \(response.message)")
                            #endif
                            continuation.resume(throwing: UserError.serverError(response.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("👤 User profile loaded - nickname: \(data.nickname)")
                        #endif
                        continuation.resume(returning: data)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - 프로필 수정
    public func updateProfile(request: ProfileUpdateRequest) async throws -> ProfileUpdateResponse {
        // Mock 데이터 사용 시
        if MockConfig.useMockData {
            #if DEBUG
            print("👤 Using mock profile update")
            #endif
            return ProfileUpdateResponse(
                nickName: request.nickName,
                birth: request.birth,
                gender: request.gender,
                address: request.address,
                resolution: request.resolution
            )
        }
        
        let path = "api/profile"
        
        #if DEBUG
        print("👤 Updating profile: PATCH /\(path)")
        #endif
        
        let publisher: AnyPublisher<ProfileUpdateAPIResponse, APIClientError> = apiClient.request(
            path: path,
            method: .patch,
            body: request,
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
                            print("👤 Profile update error: \(error)")
                            #endif
                            continuation.resume(throwing: UserRepository.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard response.isSuccess, let data = response.data else {
                            #if DEBUG
                            print("👤 Profile update failed: \(response.message)")
                            #endif
                            continuation.resume(throwing: UserError.serverError(response.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("👤 Profile updated successfully")
                        #endif
                        continuation.resume(returning: data)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - 프로필 이미지 수정
    public func updateProfileImage(imageBase64: String) async throws -> String {
        // Mock 데이터 사용 시
        if MockConfig.useMockData {
            #if DEBUG
            print("👤 Using mock profile image update")
            #endif
            return "https://example.com/profile/updated.jpg"
        }
        
        let path = "api/profile/image"
        let body = ProfileImageRequest(profileImage: imageBase64)
        
        #if DEBUG
        print("👤 Updating profile image: PATCH /\(path)")
        #endif
        
        // 서버가 200 + 빈 body 반환하므로 ModelsShared.EmptyResponse 사용
        let publisher: AnyPublisher<ModelsShared.EmptyResponse, APIClientError> = apiClient.request(
            path: path,
            method: .patch,
            body: body,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            // 디코딩 실패는 빈 응답일 수 있음 - 성공으로 처리
                            if case .decoding = error {
                                #if DEBUG
                                print("👤 Profile image updated (empty response)")
                                #endif
                                continuation.resume(returning: "")
                            } else {
                                #if DEBUG
                                print("👤 Profile image update error: \(error)")
                                #endif
                                continuation.resume(throwing: UserRepository.mapAPIError(error))
                            }
                        case .finished:
                            break
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in
                        #if DEBUG
                        print("👤 Profile image updated successfully")
                        #endif
                        continuation.resume(returning: "")
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - 내 피드 목록 조회
    public func fetchMyFeeds(page: Int, size: Int) async throws -> FeedListResponse {
        // Mock 데이터 사용 시
        if MockConfig.useMockData {
            #if DEBUG
            print("📷 Using mock my feeds")
            #endif
            return FeedListResponse(
                content: [
                    FeedListItem(feedId: 1, feedUrl: "https://example.com/feed1.jpg", day: 1),
                    FeedListItem(feedId: 2, feedUrl: "https://example.com/feed2.jpg", day: 2),
                    FeedListItem(feedId: 3, feedUrl: "https://example.com/feed3.jpg", day: 3),
                    FeedListItem(feedId: 4, feedUrl: "https://example.com/feed4.jpg", day: 4)
                ],
                number: page,
                size: size,
                numberOfElements: 4,
                hasNext: false
            )
        }
        
        // 실제 API 호출
        let path = "feed/my?page=\(page)&size=\(size)"
        
        #if DEBUG
        print("📷 Fetching my feeds from API: GET /\(path)")
        #endif
        
        typealias MyFeedsAPIResponse = APIResponse<FeedListResponse>
        let publisher: AnyPublisher<MyFeedsAPIResponse, APIClientError> = apiClient.request(
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
                            print("📷 My feeds error: \(error)")
                            #endif
                            continuation.resume(throwing: UserRepository.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { apiResponse in
                        guard apiResponse.isSuccess, let feedListResponse = apiResponse.data else {
                            #if DEBUG
                            print("📷 My feeds failed: \(apiResponse.message)")
                            #endif
                            continuation.resume(throwing: UserRepository.mapAPIError(APIClientError.http(statusCode: apiResponse.statusCode, data: nil)))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("📷 My feeds loaded - count: \(feedListResponse.content.count)")
                        #endif
                        continuation.resume(returning: feedListResponse)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - 포인트 내역 조회
    public func fetchPoints() async throws -> PointData {
        // Mock 데이터 사용 시
        if MockConfig.useMockData {
            #if DEBUG
            print("💰 Using mock points")
            #endif
            // 목업 데이터: 다양한 포인트 내역 생성
            let calendar = Calendar.current
            let today = Date()
            
            var mockPoints: [PointItem] = []
            
            // 적립 내역 (최근 30일)
            mockPoints.append(PointItem(
                id: 1,
                name: "챌린지 인증 완료",
                status: .earn,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -2, to: today)!),
                period: 30
            ))
            mockPoints.append(PointItem(
                id: 2,
                name: "챌린지 인증 완료",
                status: .earn,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -5, to: today)!),
                period: 30
            ))
            mockPoints.append(PointItem(
                id: 3,
                name: "챌린지 인증 완료",
                status: .earn,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -10, to: today)!),
                period: 30
            ))
            mockPoints.append(PointItem(
                id: 4,
                name: "챌린지 인증 완료",
                status: .earn,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -15, to: today)!),
                period: 30
            ))
            mockPoints.append(PointItem(
                id: 5,
                name: "챌린지 달성 보너스",
                status: .earn,
                value: 500,
                date: formatDate(calendar.date(byAdding: .day, value: -20, to: today)!),
                period: 30
            ))
            mockPoints.append(PointItem(
                id: 6,
                name: "챌린지 인증 완료",
                status: .earn,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -25, to: today)!),
                period: 30
            ))
            
            // 사용 내역
            mockPoints.append(PointItem(
                id: 7,
                name: "챌린지 참여",
                status: .use,
                value: 1000,
                date: formatDate(calendar.date(byAdding: .day, value: -3, to: today)!),
                period: 0
            ))
            mockPoints.append(PointItem(
                id: 8,
                name: "챌린지 참여",
                status: .use,
                value: 1000,
                date: formatDate(calendar.date(byAdding: .day, value: -12, to: today)!),
                period: 0
            ))
            mockPoints.append(PointItem(
                id: 9,
                name: "챌린지 참여",
                status: .use,
                value: 1000,
                date: formatDate(calendar.date(byAdding: .day, value: -18, to: today)!),
                period: 0
            ))
            
            // 소멸 내역
            mockPoints.append(PointItem(
                id: 10,
                name: "소멸",
                status: .expire,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -7, to: today)!),
                period: 0
            ))
            mockPoints.append(PointItem(
                id: 11,
                name: "소멸",
                status: .expire,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -14, to: today)!),
                period: 0
            ))
            mockPoints.append(PointItem(
                id: 12,
                name: "소멸",
                status: .expire,
                value: 120,
                date: formatDate(calendar.date(byAdding: .day, value: -22, to: today)!),
                period: 0
            ))
            
            // 총 포인트 계산 (적립 - 사용 - 소멸)
            let totalEarned = mockPoints.filter { $0.status == .earn }.reduce(0) { $0 + $1.value }
            let totalUsed = mockPoints.filter { $0.status == .use }.reduce(0) { $0 + $1.value }
            let totalExpired = mockPoints.filter { $0.status == .expire }.reduce(0) { $0 + $1.value }
            let total = totalEarned - totalUsed - totalExpired
            
            return PointData(
                total: max(0, total),
                points: mockPoints.sorted { item1, item2 in
                    // 날짜 내림차순 정렬 (최신순)
                    item1.date > item2.date
                }
            )
        }
        
        // 실제 API 호출
        let path = "api/mypage/point"
        
        #if DEBUG
        print("💰 Fetching points from API: GET /\(path)")
        #endif
        
        let publisher: AnyPublisher<PointResponse, APIClientError> = apiClient.request(
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
                            print("💰 Points error: \(error)")
                            #endif
                            continuation.resume(throwing: UserRepository.mapAPIError(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        guard response.statusCode == 200 else {
                            #if DEBUG
                            print("💰 Points failed: \(response.message)")
                            #endif
                            continuation.resume(throwing: UserError.serverError(response.message))
                            cancellable?.cancel()
                            return
                        }
                        
                        #if DEBUG
                        print("💰 Points loaded - total: \(response.data.total), count: \(response.data.points.count)")
                        #endif
                        continuation.resume(returning: response.data)
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Helper
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Error Mapping
    private static func mapAPIError(_ error: APIClientError) -> UserError {
        switch error {
        case .http(let statusCode, _):
            return .http(statusCode: statusCode)
        case .network:
            return .networkError
        case .decoding:
            return .decodingError
        case .invalidURL:
            return .invalidURL
        }
    }
}

// MARK: - UserError
public enum UserError: Error {
    case http(statusCode: Int)
    case networkError
    case decodingError
    case invalidURL
    case serverError(String)
}

