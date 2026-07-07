//
//  ChallengeCommandRepoImpl.swift
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

public final class ChallengeCommandRepository: ChallengeCommandRepositoryProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // 챌린지 생성
    public func createChallenge(request: ChallengeCreateRequest, infoImages: [Data], certImages: [Data]) async throws -> ChallengeCreateResponse {
        let path = "challenge"
        
        // 1. 전체 응답(상자)을 APIResponse 타입으로 먼저 받습니다.
        let response: APIResponse<ChallengeCreateResponse> = try await apiClient.upload(
            path: path,
            method: .post,
            formData: { formData in
                // JSON 데이터
                if let jsonData = try? JSONEncoder().encode(request) {
#if DEBUG
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        print("📤 Challenge Create Request JSON: \(jsonString)")
                    }
#endif
                    formData.append(jsonData, withName: "data", mimeType: "application/json")
                }
                
                // 대표 이미지들
                infoImages.enumerated().forEach { i, data in
                    formData.append(data, withName: "infoImages", fileName: "info_\(i).jpg", mimeType: "image/jpeg")
                }
                
                // 인증 예시 이미지들
                certImages.enumerated().forEach { i, data in
                    formData.append(data, withName: "certImages", fileName: "cert_\(i).jpg", mimeType: "image/jpeg")
                }
            },
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        // 2. 상자가 성공인지 확인하고 알맹이(data)를 꺼냅니다.
        guard response.isSuccess, let createdData = response.data else {
            // 실패 시 서버 메시지를 담아 에러를 던집니다.
            throw NSError(domain: "ChallengeError", code: -1, userInfo: [NSLocalizedDescriptionKey: response.message])
        }
            
            // 3. 진짜 결과물만 리턴!
            return createdData
        }
    // 챌린지 참여
    public func participateInChallenge(challengeId: Int) async throws {
        let path = "challenge/\(challengeId)/join"
        
        let response: ChallengeJoinResponse = try await apiClient.request(
            path: path,
            method: .post,
            body: EmptyRequest(),
            encoder: JSONParameterEncoder.default,
            headers: APIClient.jsonHeaders,
            interceptor: nil
        )
        guard response.isSuccess else {
            throw ChallengeError.serverError(response.message)
        }
    }
    
    public func likeChallenge(challengeId: Int) async throws {
        let path = "challenge/\(challengeId)/like"
        
        let response: APIResponse<String> = try await apiClient.request(
            path: path,
            method: .post,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess else {
            throw ChallengeError.serverError(response.message)
        }
    }

    public func unlikeChallenge(challengeId: Int) async throws {
        let path = "challenge/\(challengeId)/like"
        
        let response: APIResponse<String> = try await apiClient.request(
            path: path,
            method: .delete,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        guard response.isSuccess else {
            throw ChallengeError.serverError(response.message)
        }
    }

    public func reportChallenge(challengeId: Int, reason: String, detail: String? = nil) async throws {
        let path = "challenge/\(challengeId)/report"

        do {
            let response: APIResponse<String> = try await apiClient.request(
                path: path,
                method: .post,
                body: ChallengeReportRequest(reason: reason, detail: detail),
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
}

