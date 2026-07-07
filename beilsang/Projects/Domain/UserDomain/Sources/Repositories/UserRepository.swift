//
//  UserRepository.swift
//  UserDomain
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import ModelsShared
import NetworkCore
import Alamofire

public final class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    public init(baseURL: String) {
        self.apiClient = APIClient(baseURL: baseURL)
    }
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - 사용자 프로필 조회 (여러 엔드포인트 병렬 조합)
    public func fetchUserProfile() async throws -> UserProfileData {
        async let nicknameFetch = fetchNickname()
        async let profileImageFetch = fetchProfileImage()
        async let challengeCountFetch = fetchChallengeCount()
        async let feedCountFetch = fetchFeedCount()
        async let likeCountFetch = fetchLikeCount()
        async let pointsFetch = fetchPoints()

        let nickName = (try? await nicknameFetch) ?? ""
        let profileImage: String? = (try? await profileImageFetch) ?? nil
        let challengeCount = (try? await challengeCountFetch) ?? ChallengeCountData(challenges: 0, successChallenge: 0, failedChallenges: 0)
        let feedCount = (try? await feedCountFetch) ?? 0
        let likeCount = (try? await likeCountFetch) ?? 0
        let points = (try? await pointsFetch) ?? PointData(total: 0, point: [])

        #if DEBUG
        print("📊 fetchUserProfile done — nick:\(nickName), likes:\(likeCount), challenges:\(challengeCount.challenges), feed:\(feedCount), point:\(points.total)")
        #endif

        // 취소된 경우 try?가 삼킨 CancellationError를 재전파 - 유효한 프로필을 빈 데이터로 덮어쓰는 것을 방지
        try Task.checkCancellation()

        return UserProfileData(
            points: points.total,
            nickName: nickName,
            profileImage: profileImage?.isEmpty == false ? profileImage : nil,
            countFeed: feedCount,
            challenges: challengeCount.challenges,
            failedChallenges: challengeCount.failedChallenges,
            successChallenge: challengeCount.successChallenge,
            likes: likeCount
        )
    }
    
    // MARK: - 프로필 수정
    public func updateProfile(request: ProfileUpdateRequest) async throws -> ProfileUpdateResponse {
        let body = NicknameUpdateRequest(nickName: request.nickName)
        let response: APIResponse<NicknameData> = try await apiClient.request(
            path: "api/nickname",
            method: .patch,
            body: body,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserError.serverError(response.message)
        }
        
        return ProfileUpdateResponse(
            nickName: data.nickName,
            birth: request.birth,
            gender: request.gender,
            address: request.address,
            resolution: request.resolution
        )
    }
    
    // MARK: - 닉네임 조회
    public func fetchNickname() async throws -> String {
        let response: APIResponse<NicknameData> = try await apiClient.request(
            path: "api/nickname",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserError.serverError(response.message)
        }
        
        return data.nickName
    }
    
    // MARK: - 닉네임 수정
    public func updateNickname(_ nickName: String) async throws -> String {
        let body = NicknameUpdateRequest(nickName: nickName)
        let response: APIResponse<NicknameData> = try await apiClient.request(
            path: "api/nickname",
            method: .patch,
            body: body,
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserError.serverError(response.message)
        }
        
        return data.nickName
    }
    
    // MARK: - 닉네임 중복 체크
    public func checkNickname(_ nickname: String) async throws -> Bool {
        guard !nickname.isEmpty else {
            throw UserError.serverError("닉네임이 올바르지 않습니다.")
        }
        
        guard let encoded = nickname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw UserError.serverError("닉네임 인코딩 실패")
        }
        
        let response: APIResponse<String> = try await apiClient.request(
            path: "api/oauth/nickname?nickname=\(encoded)",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        switch response.statusCode {
        case 200: return true
        case 400: return false
        default: throw UserError.serverError(response.message)
        }
    }
    
    // MARK: - 프로필 이미지 조회
    public func fetchProfileImage() async throws -> String? {
        let response: APIResponse<ProfileImageData> = try await apiClient.request(
            path: "api/profile-image",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserError.serverError(response.message)
        }
        
        return data.profileUrl
    }
    
    // MARK: - 프로필 이미지 수정 (multipart/form-data)
    public func updateProfileImage(imageData: Data) async throws -> String {
        let response: APIResponse<String> = try await apiClient.upload(
            path: "api/profile-image",
            method: .patch,
            formData: { formData in
                formData.append(
                    imageData,
                    withName: "profileImage",
                    fileName: "profile_\(Date().timeIntervalSince1970).jpg",
                    mimeType: "image/jpeg"
                )
            },
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess else {
            throw UserError.serverError(response.message)
        }
        
        return response.data ?? ""
    }
    
    // MARK: - 챌린지 개수 조회
    public func fetchChallengeCount() async throws -> ChallengeCountData {
        let response: APIResponse<ChallengeCountData> = try await apiClient.request(
            path: "api/challenge/count",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserError.serverError(response.message)
        }
        
        return data
    }
    
    // MARK: - 피드 개수 조회
    public func fetchFeedCount() async throws -> Int {
        let response: APIResponse<FeedCountData> = try await apiClient.request(
            path: "api/feed/count",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserError.serverError(response.message)
        }
        
        return data.countFeed
    }
    
    // MARK: - 찜 개수 조회
    public func fetchLikeCount() async throws -> Int {
        let response: APIResponse<LikeCountData> = try await apiClient.request(
            path: "api/like/count",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            #if DEBUG
            print("❌ fetchLikeCount failed: \(response.message), data: \(String(describing: response.data))")
            #endif
            throw UserError.serverError(response.message)
        }
        
        #if DEBUG
        print("💙 fetchLikeCount: \(data.likes)")
        #endif
        
        return data.likes
    }
    
    // MARK: - 내 피드 목록 조회
    public func fetchMyFeeds(page: Int, size: Int) async throws -> FeedListResponse {
        let response: APIResponse<FeedListResponse> = try await apiClient.request(
            path: "feed/my?page=\(page)&size=\(size)",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserRepository.mapAPIError(APIClientError.http(statusCode: response.statusCode, data: nil))
        }
        
        return data
    }
    
    // MARK: - 포인트 내역 조회
    public func fetchPoints() async throws -> PointData {
        let response: APIResponse<PointAPIResponseData> = try await apiClient.request(
            path: "api/point",
            method: .get,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        guard response.isSuccess, let data = response.data else {
            throw UserError.serverError(response.message)
        }
        
        return PointData(total: data.total, point: data.points)
    }
    
    private static func mapAPIError(_ error: APIClientError) -> UserError {
        switch error {
        case .http(let statusCode, _): return .http(statusCode: statusCode)
        case .network: return .networkError
        case .decoding: return .decodingError
        case .invalidURL: return .invalidURL
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
