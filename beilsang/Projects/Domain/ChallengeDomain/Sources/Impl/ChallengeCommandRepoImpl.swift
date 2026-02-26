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

public final class ChallengeCommandRepoImpl: ChallengeCommandRepositoryProtocol {
    private let apiClient: APIClientProtocol

    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    // MARK: - Participate in Challenge
    public func participateInChallenge(challengeId: Int) async throws {
        if MockConfig.useMockData {
            #if DEBUG
            print("🎯 Using mock challenge participation - ID: \(challengeId)")
            #endif
            return
        }
        
        let path = "challenge/\(challengeId)/join"
        
        #if DEBUG
        print("🎯 Joining challenge - ID: \(challengeId)")
        #endif
        
        let publisher: AnyPublisher<ChallengeJoinResponse, APIClientError> = apiClient.request(
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
                            print("🎯 Challenge join error: \(error)")
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
                            
                            #if DEBUG
                            if let data = response.data {
                                print("🎯 Challenge joined - Remaining points: \(data.remainingPoint)")
                            }
                            #endif
                            
                            continuation.resume()
                        } catch {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    }
                )
        }
    }
    
    // MARK: - Report Challenge
    public func reportChallenge(challengeId: Int) async throws {
        if MockConfig.useMockData {
            #if DEBUG
            print("🚨 Using mock challenge report - ID: \(challengeId)")
            #endif
            return
        }
        
        // TODO: POST /api/challenges/{challengeId}/report
        throw ChallengeError.notImplemented
    }
    
    // MARK: - Create Challenge
    public func createChallenge(request: ChallengeCreateRequest, infoImages: [Data], certImages: [Data]) async throws -> ChallengeCreateResponse {
        if MockConfig.useMockData {
            #if DEBUG
            print("🎯 Using mock challenge creation: \(request.title)")
            #endif
            return ChallengeCreateResponse(
                challengeId: 999,
                category: request.category,
                title: request.title,
                startDate: request.startDate,
                finishDate: "",
                joinPoint: request.joinPoint,
                infoImageUrls: [],
                certImageUrls: [],
                details: request.details,
                challengeNotes: request.notes,
                period: request.period.rawValue,
                totalGoalDay: request.totalGoalDay,
                attendeeCount: 0,
                countLikes: 0,
                collectedPoint: 0
            )
        }
        
        let path = "challenge"
        
        #if DEBUG
        print("🎯 Creating challenge: \(request.title)")
        print("   infoImages: \(infoImages.count)개, certImages: \(certImages.count)개")
        #endif
        
        let publisher: AnyPublisher<ModelsShared.EmptyResponse, APIClientError> = apiClient.uploadChallengeMultipart(
            path: path,
            data: request,
            infoImages: infoImages,
            certImages: certImages,
            headers: APIClient.defaultHeaders,
            interceptor: nil
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = publisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            if case .decoding = error {
                                #if DEBUG
                                print("🎯 Challenge created (empty response)")
                                #endif
                                let emptyResponse = ChallengeCreateResponse(
                                    challengeId: 0,
                                    category: request.category,
                                    title: request.title,
                                    startDate: request.startDate,
                                    finishDate: "",
                                    joinPoint: request.joinPoint,
                                    infoImageUrls: [],
                                    certImageUrls: [],
                                    details: request.details,
                                    challengeNotes: request.notes,
                                    period: request.period.rawValue,
                                    totalGoalDay: request.totalGoalDay,
                                    attendeeCount: 0,
                                    countLikes: 0,
                                    collectedPoint: 0
                                )
                                continuation.resume(returning: emptyResponse)
                            } else {
                                #if DEBUG
                                print("🎯 Challenge create error: \(error)")
                                #endif
                                continuation.resume(throwing: ChallengeRepositoryHelpers.mapAPIError(error))
                            }
                        case .finished:
                            break
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in
                        #if DEBUG
                        print("🎯 Challenge created successfully")
                        #endif
                        let emptyResponse = ChallengeCreateResponse(
                            challengeId: 0,
                            category: request.category,
                            title: request.title,
                            startDate: request.startDate,
                            finishDate: "",
                            joinPoint: request.joinPoint,
                            infoImageUrls: [],
                            certImageUrls: [],
                            details: request.details,
                            challengeNotes: request.notes,
                            period: request.period.rawValue,
                            totalGoalDay: request.totalGoalDay,
                            attendeeCount: 0,
                            countLikes: 0,
                            collectedPoint: 0
                        )
                        continuation.resume(returning: emptyResponse)
                        cancellable?.cancel()
                    }
                )
        }
    }
}

